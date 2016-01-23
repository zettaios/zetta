//
//  ConnectionViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/23/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class ConnectionViewController: UITableViewController {

	private let cellIdentifier = "Cell"
	
	convenience init() {
		self.init(style: .Grouped)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Connection History"
		
		tableView.rowHeight = 65
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "App Server Connection History".uppercaseString
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NSUserDefaults.standardUserDefaults().connectionHistory.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let connections = NSUserDefaults.standardUserDefaults().connectionHistory
		if indexPath.row == connections.count {
			let cell = UITableViewCell()
			cell.textLabel?.text = "Add Another App Server..."
			cell.textLabel?.textColor = view.tintColor
			return cell
		}
		
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
		let connection = NSUserDefaults.standardUserDefaults().connectionHistory[indexPath.row]
		cell.textLabel?.text = connection
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
}
