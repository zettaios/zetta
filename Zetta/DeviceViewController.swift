//
//  DeviceViewController.swift
//  Zetta
//
//  Created by Ben Packard on 2/12/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit
import SwiftyJSON

class DeviceViewController: UITableViewController {
	var foregroundColor: UIColor = UIColor.blackColor() {
		didSet {
			view.tintColor = foregroundColor
			navigationController?.navigationBar.tintColor = foregroundColor
			tableView.reloadData()
		}
	}
	
	var backgroundColor: UIColor = UIColor.whiteColor() {
		didSet {
			tableView.backgroundColor = backgroundColor
			tableView.tableHeaderView?.backgroundColor = backgroundColor
			tableView.indicatorStyle = backgroundColor.isLight ? .Black : .White
			tableView.reloadData()
		}
	}
	
	private var device: ZIKDevice
	private var monitoredStreams = [ZIKStream]()
	private var mostRecentStreamValues = [ZIKStream: AnyObject]()
	private var logsStream: ZIKStream? //so it can be identified and excluded from streams section
	private var logs = [ZIKLogStreamEntry]()
	
	private let billboardCellIdentifier = "Billboard Cell"
	private let propertyCellIdentifier = "Property Cell"
	private let noFieldsActionCellIdentifier = "No Fields Action Cell"
	private let singleFieldActionCellIdentifier = "Single Field Action Cell"
	private let logsCellIdentifier = "Logs Cell"
	
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
		navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
		
		submitAnalytics()
		
		tableView.tableFooterView = UIView()
		tableView.registerClass(BillboardCell.self, forCellReuseIdentifier: billboardCellIdentifier)
		tableView.registerClass(PropertyCell.self, forCellReuseIdentifier: propertyCellIdentifier)
		tableView.registerClass(NoFieldsActionCell.self, forCellReuseIdentifier: noFieldsActionCellIdentifier)
		tableView.registerClass(SingleFieldActionCell.self, forCellReuseIdentifier: singleFieldActionCellIdentifier)
		tableView.registerClass(PropertyCell.self, forCellReuseIdentifier: logsCellIdentifier)
		tableView.keyboardDismissMode = .OnDrag
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		
		navigationController?.navigationBar.barStyle = backgroundColor.isLight ? .Default : .Black
		navigationController?.navigationBar.tintColor = foregroundColor
		if navigationController?.navigationBar.barTintColor != backgroundColor {
			UIView.animateWithDuration(0.3) { [weak self] () -> Void in
				self?.navigationController?.navigationBar.barTintColor = self?.backgroundColor
			}
		}
	}
	
	private func submitAnalytics() {
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: title)
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
	}
	
	// MARK: - monitoring streams
	
	private func monitorStreams() {
		//only monitor streams with `rel: monitor`
		guard let links = self.device.links as? [ZIKLink] else { return }
		let monitoredLinks = links.filter({ (link) -> Bool in
			if let rels = link.rel as? [String] where rels.contains("monitor") {
				return true
			}
			return false
		})

		for link in monitoredLinks {
			let stream = ZIKStream(link: link, andIsMultiplex: false)
			if link.title == "logs" { //we want to be able to identify the logs stream later
				self.logsStream = stream
			}
			self.monitoredStreams.append(stream)
		}
		
		//when a log entry is received, use it to refresh the device. Store the most recent value for each stream, and all values for the logs stream.
		for stream in self.monitoredStreams {
			stream.signal.subscribeNext({ [weak self] (streamEntry) -> Void in
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					if let streamEntry = streamEntry as? ZIKLogStreamEntry {
						self?.device.refreshWithLogEntry(streamEntry)
						self?.logs.insert(streamEntry, atIndex: 0)
						self?.updateStateImage()
					} else if let streamEntry = streamEntry as? ZIKStreamEntry {
						self?.mostRecentStreamValues[stream] = streamEntry.data
					}

					//TO DO: - only reload where necessary (including billboards)
					self?.tableView.reloadData()
				})
			})
			stream.resume()
		}
	}
	
	// data helpers
	
	private enum DisplayStyle: String {
		case None = "none", Billboard = "billboard", Inline = "inline"
	}
	
	private func displayStyleForTranstion(transition: ZIKTransition) -> DisplayStyle {
		let defaultStyle: DisplayStyle = .Inline
		guard let actionStyles = JSON(device.properties)["style"]["actions"].array else { return defaultStyle }
		let matchingActionStyles = actionStyles.filter({ $0["action"].string == transition.name })
		if matchingActionStyles.count > 1 { print("Warning: multiple styles specified for action'\(transition.name)'. The first style will be used.") }
		guard let displayString = matchingActionStyles.first?["display"].string else { return defaultStyle }
		return DisplayStyle(rawValue: displayString) ?? defaultStyle
	}
	
	private var nonHiddenTransitions: [ZIKTransition] {
		guard let transitions = device.transitions as? [ZIKTransition] else { return [ZIKTransition]() }
		return transitions.filter({ displayStyleForTranstion($0) != .None })
	}
	
	private struct BillboardStream {
		let stream: ZIKStream
		let symbol: String?
		let significantDigits: Int?
		
		init(stream: ZIKStream, symbol: String?, significantDigits: Int?) {
			self.stream = stream
			self.symbol = symbol
			self.significantDigits = significantDigits
		}
	}
	
	private var billboardStreams: [BillboardStream] {
		//find the streams who appear in the style object with `display:billboard` and use them to build a Billboard object
		let styleProperties = JSON(device.properties)["style"]["properties"].array
		let billboardStyleProperties = styleProperties?.filter({ $0["display"].string == "billboard" }) ?? [JSON]()
		var results = [BillboardStream]()
		for style in billboardStyleProperties {
			let property = style["property"].string
			let matchingStreams = nonLogStreams.filter({ $0.title == property })
			if matchingStreams.count > 1 { print("Warning: multiple streams found for billboarded property '\(property)'. The first stream will be used.") }
			guard let stream = matchingStreams.first else { continue }
			let symbol = style["symbol"].string
			let significantDigits = style["significantDigits"].int
			results.append(BillboardStream.init(stream: stream, symbol: symbol, significantDigits: significantDigits))
		}
		return results
	}
	
	private var hideDeviceIcon: Bool {
		let styleProperties = JSON(device.properties)["style"]["properties"].array
		let stateImageProperties = styleProperties?.filter({ $0["property"] == "stateImage" }) ?? [JSON]()
		if stateImageProperties.count > 1 { print("Warning: multiple styles found for stateImage. The first style will be used.") }
		guard let stateImageProperty = stateImageProperties.first else { return false }
		return stateImageProperty["display"] == "none"
	}
	
	private var showIcon: Bool {
		return true
	}
	
	private var nonLogStreams: [ZIKStream] {
		return monitoredStreams.filter({ $0 != logsStream })
	}
	
	// MARK: - updating state image
	
	lazy var iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .ScaleAspectFit
		return imageView
	}()
	
	private lazy var nonCachingSession: NSURLSession = {
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		config.requestCachePolicy = .ReloadIgnoringLocalCacheData
		return NSURLSession(configuration: config)
	}()

	private func updateStateImage() {
		guard let iconURL = device.iconURL else {
			iconImageView.image = UIImage(named: "Device Placeholder")?.imageWithRenderingMode(.AlwaysOriginal)
			return
		}

		iconImageView.sd_setImageWithURL(iconURL, placeholderImage: UIImage(), options: .RefreshCached, completed: { [weak self] (image, error, cacheType, _) -> Void in
			if let error = error { print("Error downloading state image: \(error)") }
			guard let image = image else { return }
			self?.iconImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
		})
	}

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return nil
		case 1: return nil
		case 2: return "Streams"
		case 3: return "Actions"
		case 4: return "Properties"
		case 5: return "Events"
		default: return nil
		}
	}

	override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let header = view as? UITableViewHeaderFooterView {
			header.textLabel?.textColor = backgroundColor.isLight ? UIColor.appDarkGrayColor() : UIColor.whiteColor()
		}
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section < 2 ? tableView.bounds.width : 60
	}
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return billboardStreams.count
		case 1: return device.iconURL != nil && hideDeviceIcon == false ? 1 : 0
		case 2: return max(nonLogStreams.count, 1)
		case 3: return max(nonHiddenTransitions.count, 1)
		case 4: return max(device.properties.count, 1)
		case 5: return 1
		default: return 0
		}
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			return billboardCellForIndexPath(indexPath)
		case 1:
			return iconCell
		case 2:
			return nonLogStreams.isEmpty ? UITableViewCell.emptyCell(message: "No streams for this device.") : streamCellForIndexPath(indexPath)
		case 3:
			return nonHiddenTransitions.isEmpty ? UITableViewCell.emptyCell(message: "No actions for this device.") : actionCellForIndexPath(indexPath)
		case 4:
			return device.properties.isEmpty ? UITableViewCell.emptyCell(message: "No properties for this device.") : propertyCellForIndexPath(indexPath)
		case 5:
			return logCell()
		default:
			return UITableViewCell()
		}
    }

	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = backgroundColor
		let appropriateColor = backgroundColor.isLight ? UIColor.appDarkGrayColor() : UIColor.whiteColor()
		if let cell = cell as? PropertyCell {
			cell.subtitleLabel.textColor = appropriateColor
		} else if let cell = cell as? SingleFieldActionCell {
			cell.textField.textColor = appropriateColor
		} else if let cell = cell as? MultipleFieldsActionCell {
			for field in cell.textFields {
				field.textColor = appropriateColor
			}
		}
	}
	
	private func billboardCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(billboardCellIdentifier) as? BillboardCell else { return UITableViewCell() }
		cell.tintColor = foregroundColor
		
		let billboard = billboardStreams[indexPath.row]
		
		cell.overLabel.text = billboard.stream.title
		cell.underLabel.text = billboard.symbol
		
		let value = mostRecentStreamValues[billboard.stream] ?? device.properties[billboard.stream.title] //perhaps there is a matching property to fall back on initial state
		if let value = value as? String {
			cell.mainLabel.text = value
		} else if let value = value as? Float {
			cell.mainLabel.font = UIFont.monospacedDigitSystemFontOfSize(cell.defaultFontSize, weight: UIFontWeightRegular)
			if let digits = billboard.significantDigits {
				cell.mainLabel.text = String(format: "%.\(digits)f", value)
			} else {
				cell.mainLabel.text = String(value)
			}
		}
		
		return cell
	}
	
	private lazy var iconCell: UITableViewCell = {
		guard let iconURL = self.device.iconURL where !self.hideDeviceIcon else { return UITableViewCell() }
		
		let cell = UITableViewCell()
		self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
		cell.contentView.addSubview(self.iconImageView)
		self.iconImageView.snp_makeConstraints { (make) -> Void in
			make.edges.equalTo(cell.contentView).inset(40)
		}

		self.updateStateImage()

		return cell
	}()
	
	private func streamCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(propertyCellIdentifier) as? PropertyCell else { return UITableViewCell() }
		
		let stream = nonLogStreams[indexPath.row]
		
		cell.titleLabel.text = stream.title
		
		if let value = mostRecentStreamValues[stream] ?? device.properties[stream.title] { //perhaps there is a matching property to fall back on initial state
			cell.subtitleLabel.text = String(value)
			if value is Float || value is Int || value is Double {
				cell.subtitleLabel.font = UIFont.monospacedDigitSystemFontOfSize(18, weight: UIFontWeightRegular)
			}
			
		}
		
		return cell
	}
	
	private func actionCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		let transition = nonHiddenTransitions[indexPath.row]
		let fieldNames = fieldNamesForTransition(transition)
		
		if fieldNames.isEmpty {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(noFieldsActionCellIdentifier) as? NoFieldsActionCell else { return UITableViewCell() }
			cell.titleLabel.text = transition.name
			cell.goButton.setTitle(transition.name, forState: .Normal)
			cell.delegate = self
			return cell
		} else if fieldNames.count == 1 {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(singleFieldActionCellIdentifier) as? SingleFieldActionCell else { return UITableViewCell() }
			if let placeholder = fieldNames.first?.stringByAppendingString("...") {
				cell.textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.appMediumGrayColor()])
			}
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
	
	private func logCell() -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(logsCellIdentifier) as? PropertyCell else { return UITableViewCell() }
		cell.accessoryType = logs.isEmpty ? .None : .DisclosureIndicator
		cell.titleLabel.text = "View Events (\(self.logs.count))"
		return cell
	}
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return indexPath.section == 5 && !logs.isEmpty
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let controller = EventsLogViewController(eventLogs: logs)
		controller.backgroundColor = backgroundColor
		navigationController?.pushViewController(controller, animated: true)
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
					self?.updateStateImage()
					self?.tableView.reloadData()
				})
			}
		}
	}
}
