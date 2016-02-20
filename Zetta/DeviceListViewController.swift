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

	private var devices = [ZIKDevice]()
	private let cellIdentifier = "Cell"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Zetta"
		
		tableView.tableFooterView = UIView()
		tableView.registerClass(DeviceCell.self, forCellReuseIdentifier: cellIdentifier)
		
		fetchDevices()
    }
	
	// MARK: - data
	
	private func fetchDevices() {
		if let url = NSUserDefaults.standardUserDefaults().connectionHistory.first {
			fetchDevicesFromURL(url)
		}
	}
	
	//since both the server signal and the devices signal send 'completed' events, this is a 'fetch' rather than a 'monitor'
	private func fetchDevicesFromURL(url: NSURL) {
		let rootSignal = ZIKSession.sharedSession().root(url)
		let serverSignal = ZIKSession.sharedSession().servers(rootSignal)
		let devicesSignal = ZIKSession.sharedSession().devices(serverSignal)
		
		devicesSignal.collect().subscribeNext({ [unowned self] (devices) -> Void in
			guard let devices = devices as? [ZIKDevice] else { return }
			self.devices = devices
			dispatch_async(dispatch_get_main_queue(),{
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
			})
		})
	}

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

	override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 30
	}
	
	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? max(devices.count, 1) : 1
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 72 : 55
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 1 {
			return settingsCell
		} else if indexPath.section == 0 && devices.isEmpty {
			return messageCell
		} else {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? DeviceCell else {
				return UITableViewCell()
			}
			
			let device = devices[indexPath.row]
			
			cell.deviceImageView.image = UIImage(named: "Device Placeholder")
			cell.titleLabel.text = (device.name ?? device.type) ?? "Unnamed Device"
			cell.subtitleLabel.text = device.state
			
			return cell
		}
    }
	
	private var messageCell: UITableViewCell {
		let cell = UITableViewCell()
		cell.contentView.backgroundColor = UIColor.whiteColor()
		
		let spinner = UIActivityIndicatorView()
		spinner.color = UIColor.grayColor()
		spinner.startAnimating()
		spinner.translatesAutoresizingMaskIntoConstraints = false
		cell.contentView.addSubview(spinner)
		
		let label = UILabel()
		label.textColor = spinner.color
		label.font = UIFont.systemFontOfSize(12)
		label.numberOfLines = 0
		if let urlString = NSUserDefaults.standardUserDefaults().connectionHistory.first?.absoluteString {
			label.text = "Waiting for devices to join \(urlString)"
		} else {
			label.text = "Tap 'Settings' to Add an App Server..."
		}
		label.translatesAutoresizingMaskIntoConstraints = false
		cell.contentView.addSubview(label)
		
		spinner.snp_makeConstraints { (make) -> Void in
			make.centerY.equalTo(cell.contentView)
			make.left.equalTo(cell.contentView).offset(20)
		}
		
		label.snp_makeConstraints { (make) -> Void in
			make.centerY.equalTo(spinner)
			make.left.equalTo(spinner.snp_right).offset(15)
			make.right.equalTo(cell.contentView).offset(-20)
		}
		
		return cell
	}
	
	private var settingsCell: UITableViewCell {
		let cell = UITableViewCell()
		cell.backgroundColor = UIColor(red:0.290,  green:0.565,  blue:0.890, alpha:1)
		let settingsLabel = UILabel()
		settingsLabel.text = "Settings".uppercaseString
		settingsLabel.font = UIFont.systemFontOfSize(16)
		settingsLabel.textColor = UIColor.whiteColor()
		settingsLabel.translatesAutoresizingMaskIntoConstraints = false
		cell.contentView.addSubview(settingsLabel)
		settingsLabel.snp_makeConstraints { (make) -> Void in
			make.center.equalTo(cell.contentView)
		}
		return cell
	}
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		//exclude the 'no devices' message cell
		return !devices.isEmpty || indexPath.section == 1
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if indexPath.section == 1 {
			let controller = SettingsViewController()
			controller.delegate = self
			let nav = UINavigationController(rootViewController: controller)
			presentViewController(nav, animated: true, completion: nil)
		} else {
			let device = devices[indexPath.row]
			let controller = DeviceViewController(device: device)
			controller.delegate = self
			navigationController?.pushViewController(controller, animated: true)
		}
	}
}

extension DeviceListViewController: SettingsDelegate {
	
	func selectedConnectionChanged() {
		//reload everything when the url is updated
		devices.removeAll()
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
		fetchDevices()
	}
	
}

extension DeviceListViewController: DeviceDelegate {
	
	func deviceViewController(controller: DeviceViewController, didTransitionDevice device: ZIKDevice) {
		if let deviceIndex = devices.map({ $0.uuid }).indexOf(device.uuid) {
			devices[deviceIndex] = device
			tableView.reloadData()
		}
	}
	
}