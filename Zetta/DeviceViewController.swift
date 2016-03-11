//
//  DeviceViewController.swift
//  Zetta
//
//  Created by Ben Packard on 2/12/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit

class DeviceViewController: UITableViewController {

	private var device: ZIKDevice
	private var monitoredStreams = [ZIKStream]()
	private var mostRecentStreamValues = [ZIKStream: AnyObject]()
	private var logsStream: ZIKStream? //so it can be identified and excluded from streams section
	private var logs = [ZIKLogStreamEntry]()
	
	private let propertyCellIdentifier = "Property Cell"
	private let noFieldsActionCellIdentifier = "No Fields Action Cell"
	private let singleFieldActionCellIdentifier = "Single Field Action Cell"
	
	lazy var iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .ScaleAspectFit
		return imageView
	}()
	
	private lazy var dateFormatter: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.dateStyle = .ShortStyle
		formatter.timeStyle = .MediumStyle
		return formatter
	}()
	
	init(device: ZIKDevice) {
		self.device = device
		
		super.init(nibName: nil, bundle: nil)
		
		monitorStreams()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = (device.name ?? device.type) ?? "Unnamed Device"
		
		submitAnalytics()
		
		addHeader()
		updateHeader()
		
		tableView.estimatedRowHeight = 60
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.tableFooterView = UIView()
		tableView.registerClass(PropertyCell.self, forCellReuseIdentifier: propertyCellIdentifier)
		tableView.registerClass(NoFieldsActionCell.self, forCellReuseIdentifier: noFieldsActionCellIdentifier)
		tableView.registerClass(SingleFieldActionCell.self, forCellReuseIdentifier: singleFieldActionCellIdentifier)
		tableView.allowsSelection = false
		tableView.keyboardDismissMode = .OnDrag
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		for stream in monitoredStreams {
			stream.stop()
		}
	}
	
	private func submitAnalytics() {
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: title)
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
	}
	
	private func addHeader() {
		let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height * 0.5))
		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		header.addSubview(iconImageView)
		iconImageView.snp_makeConstraints { (make) -> Void in
			make.edges.equalTo(header).inset(40)
		}
		tableView.tableHeaderView = header
	}
	
	private func updateHeader() {
		if let iconURL = device.iconURL {
			iconImageView.pin_setImageFromURL(iconURL, completion: { [weak self] (result) -> Void in
				self?.iconImageView.image = result.image?.imageWithRenderingMode(.AlwaysTemplate)
			})
		} else {
			iconImageView.image = UIImage(named: "Device Placeholder")?.imageWithRenderingMode(.AlwaysOriginal)
		}
	}
	
	// MARK: - monitoring streams
	
	private func monitorStreams() {
		//monitor all streams with rel: monitor. When a log entry is received, use it to refresh the device. Store the most recent value for each stream, and all values for the logs stream.
		guard let links = self.device.links as? [ZIKLink] else { return }
		
		let monitoredLinks = links.filter({ (link) -> Bool in
			if let rels = link.rel as? [String] where rels.contains("monitor") {
				return true
			}
			return false
		})
		
		for link in monitoredLinks {
			let stream = ZIKStream(link: link, andIsMultiplex: false)
			if link.title == "logs" {
				self.logsStream = stream
			}
			self.monitoredStreams.append(stream)
		}
		
		for stream in self.monitoredStreams {
			stream.signal.subscribeNext({ [weak self] (streamEntry) -> Void in
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					if let streamEntry = streamEntry as? ZIKLogStreamEntry {
						self?.device.refreshWithLogEntry(streamEntry)
						self?.logs.insert(streamEntry, atIndex: 0)
						self?.updateHeader()
					} else if let streamEntry = streamEntry as? ZIKStreamEntry {
						self?.mostRecentStreamValues[stream] = streamEntry.data
					}
					self?.tableView.reloadData()
				})
			})
			stream.resume()
		}
	}
	
	private var nonLogStreams: [ZIKStream] {
		return monitoredStreams.filter({ $0 != logsStream })
	}
	
    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "Streams"
		case 1: return "Actions"
		case 2: return "Properties"
		case 3: return "Events"
		default: return nil
		}
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return max(nonLogStreams.count, 1)
		case 1: return max(device.transitions?.count ?? 0, 1)
		case 2: return max(device.properties.count, 1)
		case 3: return max(logs.count, 1)
		default: return 0
		}
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0: return nonLogStreams.isEmpty ? UITableViewCell.emptyCell(message: "No streams for this device.") : streamCellForIndexPath(indexPath)
		case 1: return device.transitions?.isEmpty != false ? UITableViewCell.emptyCell(message: "No actions for this device.") : actionCellForIndexPath(indexPath)
		case 2: return device.properties.isEmpty ? UITableViewCell.emptyCell(message: "No properties for this device.") : propertyCellForIndexPath(indexPath)
		case 3: return logs.isEmpty ? UITableViewCell.emptyCell(message: "No logs for this device.") : logCellForIndexPath(indexPath)
		default: return UITableViewCell()
		}
    }
	
	private func streamCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(propertyCellIdentifier) as? PropertyCell else { return UITableViewCell() }
		let stream = nonLogStreams[indexPath.row]
		cell.titleLabel.text = stream.title
		
		if let recentValue = mostRecentStreamValues[stream] as? String {
			cell.subtitleLabel.text = recentValue
			cell.subtitleLabel.font = UIFont.systemFontOfSize(18)
		} else if let recentValue = mostRecentStreamValues[stream] as? Float {
			cell.subtitleLabel.text = String(format: "%.5f", recentValue)
			cell.subtitleLabel.font = UIFont.monospacedDigitSystemFontOfSize(18, weight: UIFontWeightRegular)
		} else {
			//perhaps there is a matching property to fall back on
			cell.subtitleLabel.text = device.properties[stream.title] as? String
			cell.subtitleLabel.font = UIFont.systemFontOfSize(18)
		}
		
		return cell
	}
	
	private func actionCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let transitions = device.transitions as? [ZIKTransition] else { return UITableViewCell() }

		let transition = transitions[indexPath.row]
		let fieldNames = fieldNamesForTransition(transition)
		
		if fieldNames.isEmpty {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(noFieldsActionCellIdentifier) as? NoFieldsActionCell else { return UITableViewCell() }
			cell.titleLabel.text = transition.name
			cell.goButton.setTitle(transition.name, forState: .Normal)
			cell.delegate = self
			return cell
		} else if fieldNames.count == 1 {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(singleFieldActionCellIdentifier) as? SingleFieldActionCell else { return UITableViewCell() }
			cell.textField.placeholder = fieldNames.first?.stringByAppendingString("...")
			cell.goButton.setTitle(transition.name, forState: .Normal)
			cell.delegate = self
			return cell
		} else {
			let cell = MultipleFieldsActionCell(fieldNames: fieldNames)
			cell.goButton.setTitle(transition.name, forState: .Normal)
			cell.delegate = self
			return cell
		}
	}
	
	private func fieldNamesForTransition(transition: ZIKTransition) -> [String] {
		var fieldNames = [String]()
		if let fields = transition.fields as? [[String: AnyObject]] {
			for field in fields {
				if let type = field["type"] as? String where type != "hidden", let name = field["name"] as? String {
					fieldNames.append(name)
				}
			}
		}
		return fieldNames
	}
	
	private func propertyCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(propertyCellIdentifier) as? PropertyCell else { return UITableViewCell() }
		guard let properties = device.properties as? [String: AnyObject] else { return cell }
		
		let key = Array(properties.keys)[indexPath.row]
		cell.titleLabel.text = key
		if let value = properties[key] as? String {
			cell.subtitleLabel.text = value
		} else if let value = properties[key] as? [Int] where value.count == 3 {
			let colorView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
			colorView.backgroundColor = UIColor(colorValues: value)
			colorView.layer.cornerRadius = 3
			cell.accessoryView = colorView
		}
		
		return cell
	}
	
	private func logCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
		cell.textLabel?.font = UIFont.systemFontOfSize(16)
		cell.textLabel?.textColor = UIColor.appDarkGrayColor()
		cell.textLabel?.numberOfLines = 0
		cell.detailTextLabel?.font = UIFont.systemFontOfSize(12)
		cell.detailTextLabel?.textColor = UIColor.appMediumGrayColor()
		
		let log = logs[indexPath.row]
		let valueStrings = log.inputs.flatMap { (input) -> String? in
			if let name = input["name"] as? String, value = input["value"] as? String {
				return "\(name): \(value)"
			}
			return nil
		}
		let inputString = valueStrings.joinWithSeparator(", ")
		let logString = [log.transition, inputString.nonEmptyTrimmed()].flatMap({ $0 }).joinWithSeparator(" - ")
		cell.textLabel?.text = logString
		
		let date = NSDate(timeIntervalSince1970: log.timestamp.doubleValue / 1000)
		cell.detailTextLabel?.text = dateFormatter.stringFromDate(date)
		
		return cell
	}
	
}

extension DeviceViewController: ActionCellDelegate {
	
	func actionCell(cell: UITableViewCell, didSubmitFields fields: [String?]) {
		guard let indexPath = tableView.indexPathForCell(cell) where indexPath.row < device.transitions?.count else { return }
		guard let transition = device.transitions?[indexPath.row] as? ZIKTransition else { return }

		let fieldNames = fieldNamesForTransition(transition)
		guard fieldNames.count == fields.count else { return } //something went wrong in setup if these don't match
		
		var arguments = [String: String]()
		for (index, field) in fields.enumerate() {
			if let field = field {
				arguments[fieldNames[index]] = field
			}
		}
		
		device.transition(transition.name, withArguments: arguments) { [weak self] (error, device) -> Void in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			//a new device is returned, representing the latest state
			if let device = device {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self?.device = device
					self?.updateHeader()
					self?.tableView.reloadData()
				})
			}
		}
	}
	
}
