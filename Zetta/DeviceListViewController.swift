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
	
	private lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.hidesWhenStopped = true
		spinner.color = UIColor.grayColor()
		return spinner
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Device list"
		
		tableView.tableFooterView = UIView()
		tableView.separatorStyle = .None
		tableView.rowHeight = 72
		tableView.registerClass(DeviceCell.self, forCellReuseIdentifier: cellIdentifier)
		
		spinner.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(spinner)
		spinner.snp_makeConstraints { (make) -> Void in
			make.centerX.equalTo(view)
			make.top.equalTo(view).offset(100)
		}
		
		let temporaryURLString = "https://zetta-cloud-2.herokuapp.com/"
		guard let url = NSURL(string: temporaryURLString) else {
			print("Warning: unable to build URL from string \(temporaryURLString)")
			return
		}
		
		fetchDevicesFromURL(url)
    }
	
	// MARK: - data
	
	//since both the server signal and the devices signal send 'completed' events, this is a 'fetch' rather than a 'monitor'
	private func fetchDevicesFromURL(url: NSURL) {
		self.spinner.startAnimating()
		
		let rootSignal = ZIKSession.sharedSession().root(url)
		let serverSignal = ZIKSession.sharedSession().servers(rootSignal)
		let devicesSignal = ZIKSession.sharedSession().devices(serverSignal)
		
		devicesSignal.collect().subscribeNext({ [unowned self] (devices) -> Void in
			if let devices = devices as? [ZIKDevice] {
				self.devices = devices
			}
			
			dispatch_async(dispatch_get_main_queue(),{
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
				self.spinner.stopAnimating()
			})
		})
	}

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? DeviceCell else {
			return UITableViewCell()
		}

		guard indexPath.row < devices.count else {
			return UITableViewCell()
		}
		
		let device = devices[indexPath.row]
		
		cell.deviceImageView.image = UIImage(named: "Device Placeholder")?.imageWithRenderingMode(.AlwaysTemplate)
		cell.deviceImageView.tintColor = UIColor(white: 0.9, alpha: 1)
		cell.titleLabel.text = device.name ?? "Unnamed Device"
		cell.subtitleLabel.text = "Subtitle"
		
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
