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
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		//new connection might have been added
		tableView.reloadData()
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
			cell.textLabel?.text = connections.isEmpty ? "Add an App Server" : "Add Another App Server..."
			cell.textLabel?.textColor = view.tintColor
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
			let connection = NSUserDefaults.standardUserDefaults().connectionHistory[indexPath.row]
			cell.textLabel?.text = connection.absoluteString
			cell.textLabel?.lineBreakMode = .ByTruncatingMiddle
			cell.accessoryType = connection == connections.first ? .Checkmark : .None
			return cell
		}
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let defaults = NSUserDefaults.standardUserDefaults()
		if indexPath.row < defaults.connectionHistory.count {
			if indexPath.row == 0 { return }
			
			//update the checkmarks
			let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
			selectedCell?.accessoryType = .Checkmark
			for cell in tableView.visibleCells where cell != selectedCell {
				cell.accessoryType = .None
			}
			
			//bump the server and the row to the top of the list
			let selectedConnection = defaults.connectionHistory[indexPath.row]
			defaults.connectionHistory.removeAtIndex(indexPath.row)
			defaults.connectionHistory.insert(selectedConnection, atIndex: 0)
			tableView.moveRowAtIndexPath(indexPath, toIndexPath: NSIndexPath(forRow: 0, inSection: 0))

		} else {
			let controller = AddConnectionViewController()
			let nav = UINavigationController(rootViewController: controller)
			presentViewController(nav, animated: true, completion: nil)
		}
	}
	
}
