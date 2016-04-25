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
			stateIcon?.tintColor = foregroundColor
			stateLabel?.textColor = foregroundColor
			tableView.reloadData()
		}
	}
	
	var backgroundColor: UIColor = UIColor.whiteColor() {
		didSet {
			(navigationItem.titleView as? NavigationTitleView)?.foregroundColor = backgroundColor.isLight ? UIColor.blackColor() : UIColor.whiteColor()
			tableView.backgroundColor = backgroundColor
			tableView.tableHeaderView?.backgroundColor = backgroundColor
			tableView.indicatorStyle = backgroundColor.isLight ? .Black : .White
			tableView.reloadData()
		}
	}
	
	private var titleView: NavigationTitleView?
	private var device: ZIKDevice
	private let serverName: String?
	private var monitoredStreams = [ZIKStream]()
	private var mostRecentStreamValues = [ZIKStream: AnyObject]()
	private var logsStream: ZIKStream? //so it can be identified and excluded from streams section
	private var logs = [ZIKLogStreamEntry]()
	
	private let billboardCellIdentifier = "Billboard Cell"
	private let propertyCellIdentifier = "Property Cell"
	private let noFieldsActionCellIdentifier = "No Fields Action Cell"
	private let logsCellIdentifier = "Logs Cell"
	
	init(device: ZIKDevice, serverName: String?) {
		self.device = device
		self.serverName = serverName
		
		super.init(nibName: nil, bundle: nil)
		
		monitorStreams()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = device.name ?? device.type ?? "Unnamed Device" //needs to be set immediately since so that the title view will be built
		let titleView = NavigationTitleView(title: self.title, subtitle: self.serverName)
		titleView.foregroundColor = backgroundColor.isLight ? UIColor.blackColor() : UIColor.whiteColor()
		navigationItem.titleView = titleView
		navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
		
		submitAnalytics()
		
		tableView.tableFooterView = UIView()
		tableView.registerClass(BillboardCell.self, forCellReuseIdentifier: billboardCellIdentifier)
		tableView.registerClass(PropertyCell.self, forCellReuseIdentifier: propertyCellIdentifier)
		tableView.registerClass(NoFieldsActionCell.self, forCellReuseIdentifier: noFieldsActionCellIdentifier)
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
						self?.updateStateViews()
					} else if let streamEntry = streamEntry as? ZIKStreamEntry {
						self?.mostRecentStreamValues[stream] = streamEntry.data
					}
					self?.tableView.reloadData()
				})
			})
			stream.resume()
		}
	}
	
	// data helpers
	
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
		var results = [BillboardStream]()
		for stream in nonLogStreams {
			let styleProperties = JSON(device.properties)["style"]["properties"][stream.title]
			if styleProperties["display"].string == DisplayStyle.Billboard.rawValue {
				let symbol = styleProperties["symbol"].string
				let significantDigits = styleProperties["significantDigits"].int
				results.append(BillboardStream.init(stream: stream, symbol: symbol, significantDigits: significantDigits))
			}
		}
		return results
	}
	
	private var displayStyleForDeviceIcon: DisplayStyle {
		let defaultStyle: DisplayStyle = .Billboard
		if let displayString = JSON(device.properties)["style"]["properties"]["stateImage"]["display"].string {
			return DisplayStyle(rawValue: displayString) ?? defaultStyle
		}
		return defaultStyle
	}
	
	private var nonLogStreams: [ZIKStream] {
		return monitoredStreams.filter({ $0 != logsStream })
	}
	
	// MARK: - state views
	
	//these are set if and swhen the state cell is created
	private var stateIcon: UIImageView?
	private var stateLabel: UILabel?
	
	private func updateStateViews() {
		if let url = device.iconURL {
			stateIcon?.sd_setImageWithURL(url, placeholderImage: UIImage(), options: .RefreshCached, completed: { [weak self] (image, error, cacheType, _) -> Void in
				if let error = error { print("Error downloading state image: \(error)") }
				self?.stateIcon?.image = image.imageWithRenderingMode(self?.device.iconTintMode ?? .AlwaysTemplate)
			})
		} else {
			stateIcon?.image = UIImage(named: "Device Placeholder")?.imageWithRenderingMode(.AlwaysOriginal)
		}
		
		if let stateStream = self.monitoredStreams.filter({ $0.title == "state"}).first, recentValue = mostRecentStreamValues[stateStream] {
			stateLabel?.text = String(recentValue)
		} else if let propertyValue = device.properties["state"] {
			stateLabel?.text = String(propertyValue)
		} else {
			stateLabel?.text = nil
		}
	}
	
    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return nil
		case 1: return nil
		case 2: return "Actions"
		case 3: return "Streams"
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
		switch indexPath.section {
		case 0: return tableView.bounds.width
		case 1: return displayStyleForDeviceIcon == .Inline ? 72 : tableView.bounds.width
		case 2: return UITableViewAutomaticDimension //multi-field actions
		default: return 60
		}
	}
	
	override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section < 2 ? tableView.bounds.width : 60
	}
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return billboardStreams.count
		case 1: return displayStyleForDeviceIcon != .None && device.iconURL != nil ? 1 : 0
		case 2: return max(device.nonHiddenTransitions.count, 1)
		case 3: return max(nonLogStreams.count, 1)
		case 4: return max(device.properties.count, 1)
		case 5: return 1
		default: return 0
		}
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		
		switch indexPath.section {
		case 0: cell = billboardCellForIndexPath(indexPath)
		case 1:
			switch displayStyleForDeviceIcon {
			case .Billboard: return billboardIconCell
			case .Inline: return inlineIconCell
			default: return UITableViewCell()
			}
		case 2: cell = device.nonHiddenTransitions.isEmpty ? UITableViewCell.emptyCell(message: "No actions for this device.") : actionCellForIndexPath(indexPath)
		case 3: cell = nonLogStreams.isEmpty ? UITableViewCell.emptyCell(message: "No streams for this device.") : streamCellForIndexPath(indexPath)
		case 4: cell = device.properties.isEmpty ? UITableViewCell.emptyCell(message: "No properties for this device.") : propertyCellForIndexPath(indexPath)
		case 5: cell = logCell()
		default: cell = UITableViewCell()
		}
		
		cell.backgroundColor = backgroundColor
		cell.tintColor = foregroundColor
		return cell
    }
	
	private func billboardCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(billboardCellIdentifier) as? BillboardCell else { return UITableViewCell() }
		cell.tintColor = foregroundColor
		
		let billboard = billboardStreams[indexPath.row]
		
		cell.overLabel.text = billboard.stream.title
		cell.underLabel.text = billboard.symbol
		
		let value = mostRecentStreamValues[billboard.stream] ?? device.properties[billboard.stream.title] //perhaps there is a matching property to fall back on for initial state
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
	
	private lazy var billboardIconCell: BillboardStateCell = {
		let cell = BillboardStateCell()
		cell.backgroundColor = self.tableView.backgroundColor

		self.stateIcon = cell.iconImageView
		self.stateLabel = cell.underLabel
		self.updateStateViews()

		return cell
	}()
	
	private lazy var inlineIconCell: InlineCell = {
		let cell = InlineCell()
		cell.backgroundColor = self.tableView.backgroundColor
		let appropriateColor = cell.backgroundColor?.isLight != false ? UIColor.appDarkGrayColor() : UIColor.whiteColor()
		cell.titleLabel.textColor = appropriateColor
		cell.subtitleLabel.textColor = appropriateColor
		cell.titleLabel.text = "state"
		
		self.stateIcon = cell.deviceImageView
		self.stateLabel = cell.subtitleLabel
		self.updateStateViews()
		
		return cell
	}()
	
	private func actionCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		let transition = device.nonHiddenTransitions[indexPath.row]
		if transition.fieldNames.isEmpty {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(noFieldsActionCellIdentifier) as? NoFieldsActionCell else { return UITableViewCell() }
			cell.titleLabel.text = transition.name
			UIView.performWithoutAnimation({
				cell.goButton.setTitle(transition.name, forState: .Normal)
			})
			cell.delegate = self
			return cell
		} else if transition.fieldNames.count == 1 {
			let cell = SingleFieldActionCell(fieldName: transition.fieldNames.first ?? "")
			UIView.performWithoutAnimation({
				cell.goButton.setTitle(transition.name, forState: .Normal)
			})
			cell.delegate = self
			return cell
		} else {
			let cell = MultipleFieldsActionCell(fieldNames: transition.fieldNames)
			UIView.performWithoutAnimation({
				cell.goButton.setTitle(transition.name, forState: .Normal)
			})
			cell.delegate = self
			return cell
		}
	}
	
	private func streamCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(propertyCellIdentifier) as? PropertyCell else { return UITableViewCell() }
		
		let stream = nonLogStreams[indexPath.row]
		
		cell.titleLabel.text = stream.title
		
		if let value = mostRecentStreamValues[stream] ?? device.properties[stream.title] { //perhaps there is a matching property to fall back on for initial state
			cell.subtitleLabel.text = String(value)
			if value is Float || value is Int || value is Double {
				cell.subtitleLabel.font = UIFont.monospacedDigitSystemFontOfSize(18, weight: UIFontWeightBold)
			}
			
		}

		return cell
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
		let selectedView = UIView()
		selectedView.backgroundColor = (cell.contentView.backgroundColor ?? UIColor.lightGrayColor()).colorWithAlphaComponent(0.7)
		cell.selectedBackgroundView = selectedView
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
		guard let indexPath = tableView.indexPathForCell(cell) where indexPath.row < device.nonHiddenTransitions.count else { return }
		let transition = device.nonHiddenTransitions[indexPath.row]
		guard transition.fieldNames.count == fields.count else { return } //something went wrong in setup if these don't match
		
		var arguments = [String: String]()
		for (index, field) in fields.enumerate() {
			if let field = field {
				arguments[transition.fieldNames[index]] = field
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
					self?.updateStateViews()
					self?.tableView.reloadData()
				})
			}
		}
	}
}
