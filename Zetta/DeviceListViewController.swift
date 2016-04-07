//
//  DevicesViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit
import SDWebImage
import SwiftyJSON

class DeviceListViewController: UITableViewController {

	private var serverDevices = [(server: ZIKServer, devices:[ZIKDevice])]()
	private var mostRecentPreferredStreamValuesAndStyles = [ZIKDevice: (value: AnyObject, style: JSON)]()
	private var deviceCells = NSCache()
	
	lazy var messageLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.grayColor()
		label.font = UIFont.systemFontOfSize(12)
		label.numberOfLines = 0
		label.textAlignment = .Center
		return label
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Zetta"
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Gear Small"), style: .Plain, target: self, action: #selector(settingsButtonTapped))
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
		
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = UIColor.lightGrayColor()
		refreshControl.addTarget(self, action: #selector(pullToRefreshTrigerred(_:)), forControlEvents: .ValueChanged)
		self.refreshControl = refreshControl
		
		tableView.alwaysBounceVertical = true
		tableView.tableFooterView = UIView()
		tableView.separatorInset = UIEdgeInsetsZero
		tableView.layoutMargins = UIEdgeInsetsZero
		
		addMessageLabel()
		updateMessageView()
		
		refresh()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if navigationController?.navigationBar.barTintColor != UIColor.whiteColor() {
			UIView.animateWithDuration(0.3) { [weak self] () -> Void in
				self?.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
			}
		}
		
		navigationController?.navigationBar.tintColor = UIColor.appTintColor()
		navigationController?.navigationBar.barStyle = .Default
	}
	
	private func addMessageLabel() {
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		tableView.addSubview(messageLabel)
		messageLabel.snp_makeConstraints { (make) -> Void in
			make.centerX.equalTo(tableView)
			make.centerY.equalTo(tableView).multipliedBy(0.6)
			make.width.equalTo(tableView).multipliedBy(0.8)
		}
	}
	
	private func refresh() {
		if let url = NSUserDefaults.standardUserDefaults().connectionHistory.first {
			refreshServersFromURL(url)
		} else {
			updateMessageView()
		}
	}
	
	// MARK: - fetching servers
	
	private func refreshServersFromURL(url: NSURL) {
		serverDevices.removeAll()
		tableView.reloadData()
		updateMessageView()
		
		let rootSignal = ZIKSession.sharedSession().root(url)
		let serverSignal = ZIKSession.sharedSession().servers(rootSignal)
		serverSignal.collect().subscribeNext { (servers) -> Void in
			guard let servers = servers as? [ZIKServer] else { return }
			
			for server in servers {
				let filteredServerSignal = serverSignal.filter({ (filteredServer) -> Bool in
					guard let filteredServer = filteredServer as? ZIKServer else { return false }
					return filteredServer.name == server.name
				})
				
				ZIKSession.sharedSession().devices(filteredServerSignal).collect().subscribeNext({ (devices) -> Void in
					guard let devices = devices as? [ZIKDevice] else { return }
					
					dispatch_async(dispatch_get_main_queue(), { [weak self] in
						self?.serverDevices.append((server: server, devices: devices))
						self?.serverDevices.sortInPlace({ $0.devices.count > $1.devices.count })
						
						for device in devices {
							self?.monitorDevice(device)
						}
						
						self?.updateMessageView()
						
						if let index = self?.serverDevices.map({ $0.server }).indexOf(server) {
							self?.tableView.insertSections(NSIndexSet(index: index), withRowAnimation: .Fade)
						} else {
							self?.tableView.reloadData()
						}
					})
				})
			}
		}
	}
	
	// MARK: - monitoring streams
	
	private func monitorDevice(device: ZIKDevice) {
		//monitor all streams with rel: monitor. When a log entry is received, use it to refresh the device.
		guard let links = device.links as? [ZIKLink] else { return }
		let monitoredLinks = links.filter({ (link) -> Bool in
			if let rels = link.rel as? [String] where rels.contains("monitor") {
				return true
			}
			return false
		})
		
		for link in monitoredLinks {
			let stream = ZIKStream(link: link, andIsMultiplex: false)
			stream.signal.subscribeNext({ [weak self] (streamEntry) -> Void in
				if let streamEntry = streamEntry as? ZIKLogStreamEntry {
					//update the device and show the new state
					device.refreshWithLogEntry(streamEntry)
					if let indexPath = self?.indexPathForDevice(device) where self?.tableView.indexPathsForVisibleRows?.contains(indexPath) == true, let cell = self?.tableView.cellForRowAtIndexPath(indexPath) as? DeviceCell {
						self?.configureCell(cell, forDevice: device)
					}
				} else if let streamEntry = streamEntry as? ZIKStreamEntry {
					//some devices hide their state in preference of another property (e.g. a photocell's intensity). Values for these streams need to be collected.
					if let preferredStream = self?.preferredStyledStreamForDevice(device) where preferredStream.title == stream.title {
						self?.mostRecentPreferredStreamValuesAndStyles[device] = (value: streamEntry.data, style: preferredStream.style)
						if let indexPath = self?.indexPathForDevice(device) where self?.tableView.indexPathsForVisibleRows?.contains(indexPath) == true, let cell = self?.tableView.cellForRowAtIndexPath(indexPath) as? DeviceCell {
							self?.configureCell(cell, forDevice: device)
						}
					}
				}
			})
			stream.resume()
		}
	}

	private func indexPathForDevice(device: ZIKDevice) -> NSIndexPath? {
		for (serverIndex, serverDevice) in serverDevices.enumerate() {
			for (deviceIndex, thisDevice) in serverDevice.devices.enumerate() {
				if thisDevice == device {
					return NSIndexPath(forRow: deviceIndex, inSection: serverIndex)
				}
			}
		}
		return nil
	}
	
	private func serverForDevice(device: ZIKDevice) -> ZIKServer? {
		for serverDevice in serverDevices where serverDevice.devices.contains(device) {
			return serverDevice.server
		}
		return nil
	}
	
	private func preferredStyledStreamForDevice(device: ZIKDevice) -> (title: String, style: JSON)? {
		//some devices hide state in preference of another stream (e.g. a photocell's intensity). If so, return the style information for the preferred stream.
		guard let server = serverForDevice(device) else { return nil }
		let devicePropertyStyles = JSON(server.properties)["style"]["entities"][device.type]["properties"]
		guard devicePropertyStyles["state"]["display"].string == "none" else { return nil }
		//use any other property listed beside state (there should only be one)
		guard let nextPropertyName = devicePropertyStyles.dictionary?.keys.filter({ $0 != "state" }).first else { return nil }
		return (title: nextPropertyName, style: devicePropertyStyles[nextPropertyName])
	}
	
	// MARK: - message view
	
	private func updateMessageView() {
		if let urlString = NSUserDefaults.standardUserDefaults().connectionHistory.first?.absoluteString {
			messageLabel.text = "Waiting for devices to join \(urlString)..."
		} else {
			messageLabel.text = "Tap the Settings icon in the toolbar to add an API."
		}
		messageLabel.hidden = !serverDevices.isEmpty
	}
	
    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return serverDevices.count
    }
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 28
	}

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let server = serverDevices[section].server
		return DeviceListHeader(title: server.name, color: server.foregroundColor ?? UIColor.appDefaultDeviceTintColor())
	}
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return max(serverDevices[section].devices.count, 1)
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 72
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let devices = serverDevices[indexPath.section].devices
		if devices.isEmpty { return UITableViewCell.emptyCell(message: "No devices online for this server.") }
		let device = devices[indexPath.row]
		
		//cells are cached manually so that specfic labels can be updated quickly without interfering with gestures. Reloading the indexPath would cancel the gesture.
		let cell = deviceCells.objectForKey(device) as? DeviceCell ?? DeviceCell()
		configureCell(cell, forDevice: device)
		deviceCells.setObject(cell, forKey: device)
		return cell
    }
	
	private func configureCell(cell: DeviceCell, forDevice device: ZIKDevice) {
		let server = serverForDevice(device)
		cell.backgroundColor = device.backgroundColor ?? server?.backgroundColor
		
		let appropriateColor = cell.backgroundColor?.isLight != false ? UIColor.appDarkGrayColor() : UIColor.whiteColor()
		cell.titleLabel.textColor = appropriateColor
		cell.subtitleLabel.textColor = appropriateColor
		
		cell.titleLabel.text = device.name ?? device.type ?? "Unnamed Device"
		cell.subtitleLabel.attributedText = attributedSubtitleForDevice(device, usingFont: cell.subtitleLabel.font)
		
		if let iconURL = device.iconURL {
			cell.deviceImageView.sd_setImageWithURL(iconURL, placeholderImage: UIImage(), options: .RefreshCached, completed: { [weak self] (image, error, cacheType, _) -> Void in
				if let error = error { print("Error downloading state image: \(error)") }
				guard let image = image else { return }
				cell.deviceImageView.image = image.imageWithRenderingMode(device.iconTintMode)
				cell.deviceImageView.tintColor = device.foregroundColor ?? self?.serverForDevice(device)?.foregroundColor ?? UIColor.appDefaultDeviceTintColor()
			})
		} else {
			cell.deviceImageView.image = UIImage(named: "Device Placeholder")?.imageWithRenderingMode(.AlwaysTemplate)
			cell.deviceImageView.tintColor = UIColor(white: 0.5, alpha: serverForDevice(device)?.backgroundColor?.isLight == false ? 0.6 : 0.3)
		}
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deviceCellLongPressed(_:)))
		longPress.minimumPressDuration = 1.0
		cell.contentView.addGestureRecognizer(longPress)
	}
	
	private func attributedSubtitleForDevice(device: ZIKDevice, usingFont font: UIFont) -> NSAttributedString? {
		if let mostRecent = mostRecentPreferredStreamValuesAndStyles[device] {
			if let value = mostRecent.value as? String {
				return NSAttributedString(string: value, attributes: [NSFontAttributeName: font])
			} else if let value = mostRecent.value as? Float {
				var string: String
				if let significantDigits = mostRecent.style["significantDigits"].int {
					string = String(format: "%.\(significantDigits)f", value)
				} else {
					string = String(value)
				}
				if let symbol = mostRecent.style["symbol"].string {
					string += " \(symbol)"
				}
				return NSAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.monospacedDigitSystemFontOfSize(font.pointSize, weight: UIFontWeightBold)])
			}
		}
		
		return NSAttributedString(string: device.state ?? "", attributes: [NSFontAttributeName: font])
	}
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		//exclude the 'no devices' message cell
		return !serverDevices[indexPath.section].devices.isEmpty
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		let server = serverDevices[indexPath.section].server
		let device = serverDevices[indexPath.section].devices[indexPath.row]
		let controller = DeviceViewController(device: device)
		controller.foregroundColor = device.foregroundColor ?? server.foregroundColor ?? UIColor.appDefaultDeviceTintColor()
		controller.backgroundColor = device.backgroundColor ?? server.backgroundColor ?? UIColor.whiteColor()
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// MARK: - button actions
	
	@objc private func pullToRefreshTrigerred(refreshControl: UIRefreshControl) {
		refreshControl.endRefreshing()
		refresh()
	}
	
	@objc private func settingsButtonTapped() {
		if NSUserDefaults.standardUserDefaults().connectionHistory.isEmpty {
			let controller = AddConnectionViewController()
			controller.delegate = self
			let nav = UINavigationController(rootViewController: controller)
			presentViewController(nav, animated: true, completion: nil)
		} else {
			let controller = SettingsViewController()
			controller.delegate = self
			let nav = UINavigationController(rootViewController: controller)
			presentViewController(nav, animated: true, completion: nil)
		}
	}
	
	private lazy var mask: UIView = {
		let view = UIView(frame: self.navigationController?.view.frame ?? CGRect.zero)
		view.backgroundColor = UIColor(white: 0, alpha: 0.4)
		return view
	}()
	
	@objc private func deviceCellLongPressed(sender: UIGestureRecognizer) {
		guard sender.state == UIGestureRecognizerState.Began else { return }
		let point = sender.locationInView(tableView)
		guard let indexPath = tableView.indexPathForRowAtPoint(point) else { return }
		
		let server = serverDevices[indexPath.section].server
		let device = serverDevices[indexPath.section].devices[indexPath.row]
		if device.singleFieldNonHiddenTransitions.isEmpty { return }
		
		mask.alpha = 0
		navigationController?.view.addSubview(mask)
		UIView.animateWithDuration(0.3) { [weak self] () -> Void in
			self?.navigationController?.view.tintAdjustmentMode = .Dimmed
			self?.mask.alpha = 1
		}
		
		let controller = ActionShortcutsViewController(device: device)
		controller.modalPresentationStyle = .Custom
		controller.delegate = self
		controller.foregroundColor = device.foregroundColor ?? server.foregroundColor ?? UIColor.appDefaultDeviceTintColor()
		controller.backgroundColor = device.backgroundColor ?? server.backgroundColor ?? UIColor.whiteColor()
		presentViewController(controller, animated: true, completion: nil)
	}
}

extension DeviceListViewController: SettingsDelegate {
	func selectedConnectionChanged() {
		refresh()
	}
}

extension DeviceListViewController: ActionShortcutsDelegate {
	func didRequestDismiss() {
		UIView.animateWithDuration(0.3,
			animations: { [weak self] () -> Void in
				self?.mask.alpha = 0
				self?.navigationController?.view.tintAdjustmentMode = .Normal
			}, completion: { [weak self] (_) -> Void in
				self?.mask.removeFromSuperview()
		})
		
		dismissViewControllerAnimated(true, completion: nil)
	}
}
