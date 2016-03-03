//
//  DevicesViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit

class DeviceListViewController: UITableViewController {

	private var serverDevices = [(server: ZIKServer, devices:[ZIKDevice])]()
	private let cellIdentifier = "Cell"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Zetta"
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Gear Small"), style: .Plain, target: self, action: "settingsButtonTapped")
		
		tableView.alwaysBounceVertical = false
		tableView.tableFooterView = UIView()
		tableView.registerClass(DeviceCell.self, forCellReuseIdentifier: cellIdentifier)
		
		refresh()
    }
	
	// MARK: - data
	
	private func refresh() {
		if let url = NSUserDefaults.standardUserDefaults().connectionHistory.first {
			refreshServersFromURL(url)
		}
	}
	
	private func refreshServersFromURL(url: NSURL) {
		serverDevices.removeAll()
		tableView.reloadData()
		
		let rootSignal = ZIKSession.sharedSession().root(url)
		let serverSignal = ZIKSession.sharedSession().servers(rootSignal)
		serverSignal.collect().subscribeNext { (servers) -> Void in
			guard let servers = servers as? [ZIKServer] else { return }
			
			for server in servers {
				let filteredServerSignal = serverSignal.filter({ (filteredServer) -> Bool in
					guard let filteredServer = filteredServer as? ZIKServer else { return false }
					return filteredServer.name == server.name
				})
				
				ZIKSession.sharedSession().devices(filteredServerSignal).collect().subscribeNext({ [weak self] (devices) -> Void in
					guard let devices = devices as? [ZIKDevice] else { return }
					self?.serverDevices.append((server: server, devices: devices))
					
					dispatch_async(dispatch_get_main_queue(),{
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
			cell.deviceImageView.image = UIImage(named: "Device Placeholder")
			cell.titleLabel.text = (device.name ?? device.type) ?? "Unnamed Device"
			cell.subtitleLabel.text = device.state
			return cell
		}
    }
	
//	func messageCell() -> UITableViewCell {
//		let cell = UITableViewCell()
//		cell.contentView.backgroundColor = UIColor.whiteColor()
//		
//		let spinner = UIActivityIndicatorView()
//		spinner.color = UIColor.grayColor()
//		spinner.setContentHuggingPriority(1000, forAxis: .Horizontal)
//		
//		let label = UILabel()
//		label.textColor = spinner.color
//		label.font = UIFont.systemFontOfSize(12)
//		label.numberOfLines = 0
//		if let urlString = NSUserDefaults.standardUserDefaults().connectionHistory.first?.absoluteString {
//			label.text = "Waiting for devices to join \(urlString)..."
//			spinner.startAnimating()
//		} else {
//			label.text = "Tap 'Settings' to add an API..."
//			label.textAlignment = .Center
//			spinner.stopAnimating()
//		}
//		
//		let stack = UIStackView(arrangedSubviews: [spinner, label])
//		stack.axis = .Horizontal
//		stack.spacing = 15
//		stack.layoutMarginsRelativeArrangement = true
//		stack.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//		stack.translatesAutoresizingMaskIntoConstraints = false
//		cell.contentView.addSubview(stack)
//		stack.snp_makeConstraints { (make) -> Void in
//			make.edges.equalTo(cell.contentView)
//		}
//		
//		return cell
//	}
	
//	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//		//exclude the 'no devices' message cell
//		return !devices.isEmpty || indexPath.section == 1
//	}
//	
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