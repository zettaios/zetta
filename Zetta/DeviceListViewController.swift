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

	private var devices = [ZIKDevice]() {
		didSet {
			print("set")
		}
	}
	private var streams = [ZIKStream]()
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
	
	var tempStream: ZIKStream?
	
	//since both the server signal and the devices signal send 'completed' events, this is a 'fetch' rather than a 'monitor'
	private func fetchDevicesFromURL(url: NSURL) {
		let rootSignal = ZIKSession.sharedSession().root(url)
		let serverSignal = ZIKSession.sharedSession().servers(rootSignal)
		let devicesSignal = ZIKSession.sharedSession().devices(serverSignal)
		
		devicesSignal.collect().subscribeNext({ [unowned self] (devices) -> Void in
			if let devices = devices as? [ZIKDevice] {
				self.devices = devices
			}
			
			dispatch_async(dispatch_get_main_queue(),{
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
			})
			
			for device in self.devices where device.deviceType == .Display {
				if let stream = device.stream("message") {
//					self.streams.append(stream)
					print("adding stream")
					stream.signal.subscribeNext({ (streamEntry) -> Void in
						print("next - \(streamEntry)")
						}, error: { (_) -> Void in
							print("error")
						}, completed: { () -> Void in
							print("complete")
					})
					stream.resume()
					print(stream.title)
				}
			}
			
//				if let message = device.properties["message"] as? String {
//					print("display message: \(message)")
//				}
//				print(device.properties)
//				self.tempStream = device.stream("message")
//				print("resuming stream")
//				self.tempStream?.signal.subscribeNext({ (streamEntry) -> Void in
//					print("next - \(streamEntry)")
//					}, error: { (_) -> Void in
//						print("error")
//					}, completed: { () -> Void in
//						print("complete")
//				})
//								self.tempStream?.resume()
//			}
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
			
			cell.deviceImageView.image = UIImage(named: "Device Placeholder")?.imageWithRenderingMode(.AlwaysTemplate)
			cell.deviceImageView.tintColor = UIColor(white: 0.9, alpha: 1)
			cell.titleLabel.text = device.name ?? "Unnamed Device"
			cell.subtitleLabel.text = device.state
			
			cell.titleLabel.enabled = device.deviceType != .Unknown
			cell.subtitleLabel.enabled = device.deviceType != .Unknown
			
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
		//exclude the message cell
		if indexPath.section == 0 && devices.isEmpty { return false }
		
		//exclude unhandled device types
		if devices[indexPath.row].deviceType == DeviceType.Unknown { return false }
		
		return true
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
			print(device.name)
			if device.type == "display" {
				print(device.properties["message"])
			}
			
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