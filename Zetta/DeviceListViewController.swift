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

class DeviceListViewController: UITableViewController {

	private var serverDevices = [(server: ZIKServer, devices:[ZIKDevice])]()
	private let cellIdentifier = "Cell"
	
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
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Gear Small"), style: .Plain, target: self, action: "settingsButtonTapped")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
		
		tableView.alwaysBounceVertical = false
		tableView.tableFooterView = UIView()
		tableView.registerClass(DeviceCell.self, forCellReuseIdentifier: cellIdentifier)
		
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
	
	// MARK: - data
	
	private func refresh() {
		if let url = NSUserDefaults.standardUserDefaults().connectionHistory.first {
			refreshServersFromURL(url)
		} else {
			updateMessageView()
		}
	}
	
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
				guard let streamEntry = streamEntry as? ZIKLogStreamEntry else { return }
				let topicComponents = streamEntry.topic.componentsSeparatedByString("/")
				guard topicComponents.count >= 2 else { return }
				let deviceUUID = topicComponents[1]
				if let (device, indexPath) = self?.deviceForUUID(deviceUUID) {
					device.refreshWithLogEntry(streamEntry)
					self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
				}
			})
			stream.resume()
		}
	}
	
	private func deviceForUUID(uuid: String) -> (device: ZIKDevice, indexPath: NSIndexPath)? {
		for (serverIndex, serverDevice) in serverDevices.enumerate() {
			for (deviceIndex, device) in serverDevice.devices.enumerate() {
				if device.uuid == uuid {
					return (device: device, indexPath: NSIndexPath(forRow: deviceIndex, inSection: serverIndex))
				}
			}
		}
		return nil
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
		let server = serverDevices[indexPath.section].server
		let devices = serverDevices[indexPath.section].devices
		
		if devices.isEmpty { return UITableViewCell.emptyCell(message: "No devices online for this server.") }
		
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? DeviceCell else { return UITableViewCell() }
//		cell.contentView.backgroundColor = server.backgroundColor
//		cell.backgroundColor = server.backgroundColor
		
		let device = devices[indexPath.row]
		cell.titleLabel.text = (device.name ?? device.type) ?? "Unnamed Device"
		cell.subtitleLabel.text = device.state
		
		if let iconURL = device.iconURL {
			cell.deviceImageView.sd_setImageWithURL(iconURL, placeholderImage: UIImage(), options: .RefreshCached, completed: { [weak self] (image, error, cacheType, _) -> Void in
				if let error = error { print("Error downloading state image: \(error)") }
				guard let image = image else { return }
				cell.deviceImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
				cell.deviceImageView.backgroundColor = device.backgroundColor ?? server.backgroundColor
				cell.deviceImageView.tintColor = device.foregroundColor ?? self?.serverDevices[indexPath.section].server.foregroundColor ?? UIColor.appDefaultDeviceTintColor()
			})
		} else {
			cell.deviceImageView.backgroundColor = UIColor.whiteColor()
			cell.deviceImageView.image = UIImage(named: "Device Placeholder")?.imageWithRenderingMode(.AlwaysTemplate)
			cell.deviceImageView.tintColor = UIColor(white: 0.5, alpha: server.backgroundColor?.isLight == false ? 0.6 : 0.3)
		}
		
//		cell.backgroundColor = UIColor.whiteColor()
//		let selectedBackgroundView = UIView()
//		selectedBackgroundView.backgroundColor = server.backgroundColor?.colorWithAlphaComponent(0.8)
//		selectedBackgroundView.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
//		cell.selectedBackgroundView = selectedBackgroundView
		
		return cell
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
		controller.foregroundColor = server.foregroundColor ?? UIColor.appDefaultDeviceTintColor()
		controller.backgroundColor = server.backgroundColor ?? UIColor.whiteColor()
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// MARK: - button actions
	
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
}

extension DeviceListViewController: SettingsDelegate {
	func selectedConnectionChanged() {
		refresh()
	}
}
