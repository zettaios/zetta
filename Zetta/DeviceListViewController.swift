//
//  DevicesViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit
import PINRemoteImage

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
		
		tableView.alwaysBounceVertical = false
		tableView.tableFooterView = UIView()
		tableView.registerClass(DeviceCell.self, forCellReuseIdentifier: cellIdentifier)
		
		addMessageLabel()
		updateMessageView()
		
		refresh()
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
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return serverDevices[section].server.name
	}
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return max(serverDevices[section].devices.count, 1)
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 72
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let devices = serverDevices[indexPath.section].devices
		if devices.isEmpty {
			let cell = UITableViewCell()
			cell.textLabel?.textColor = UIColor.grayColor()
			cell.textLabel?.font = UIFont.italicSystemFontOfSize(12)
			cell.textLabel?.text = "No devices are online for this server."
			return cell
		} else {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? DeviceCell else { return UITableViewCell() }
			let device = devices[indexPath.row]
			
			cell.titleLabel.text = (device.name ?? device.type) ?? "Unnamed Device"
			cell.subtitleLabel.text = device.state
			
			if let iconURL = device.iconURL {
				cell.deviceImageView.pin_setImageFromURL(iconURL)
				cell.deviceImageView.alpha = 0.75
			} else {
				cell.deviceImageView.image = UIImage(named: "Device Placeholder")
				cell.deviceImageView.alpha = 1
			}
			
			return cell
		}
    }
		
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		//exclude the 'no devices' message cell
		return !serverDevices[indexPath.section].devices.isEmpty
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		let devices = serverDevices[indexPath.section].devices
		let device = devices[indexPath.row]
		let controller = DeviceViewController(device: device)
//		controller.delegate = self
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

//extension DeviceListViewController: DeviceDelegate {
//	
//	func deviceViewController(controller: DeviceViewController, didTransitionDevice device: ZIKDevice) {
//		if let deviceIndex = devices.map({ $0.uuid }).indexOf(device.uuid) {
//			devices[deviceIndex] = device
//			tableView.reloadData()
//		}
//	}
//	
//}