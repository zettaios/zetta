//
//  DevicesViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class DeviceListViewController: UITableViewController {

	private let cellIdentifier = "Cell"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Device list"
		
		tableView.tableFooterView = UIView()
		tableView.separatorStyle = .None
		tableView.rowHeight = 72
		tableView.registerClass(DeviceCell.self, forCellReuseIdentifier: cellIdentifier)
    }
	
	// MARK: - data
	
	private func fetchDevices() {
		
	}

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? DeviceCell else {
			return UITableViewCell()
		}

		cell.deviceImageView.image = UIImage(named: "Device Placeholder")?.imageWithRenderingMode(.AlwaysTemplate)
		cell.deviceImageView.tintColor = UIColor(white: 0.9, alpha: 1)
		cell.titleLabel.text = "Title"
		cell.subtitleLabel.text = "Subtitle"
		
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
