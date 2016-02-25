//
//  SettingsViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/23/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import SafariServices

protocol SettingsDelegate: class {
	func selectedConnectionChanged()
}

class SettingsViewController: UITableViewController {
	
	weak var delegate: SettingsDelegate?
	
	private var previousURL: NSURL?
	
	convenience init() {
		self.init(style: .Grouped)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		previousURL = NSUserDefaults.standardUserDefaults().connectionHistory.first
		
		title = "Settings"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonTapped")
		
		tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		//a new api might be added
		tableView.reloadData()
	}

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "API History".uppercaseString
		case 1: return "Build Version".uppercaseString
		case 2: return "Support".uppercaseString
		default: return nil
		}
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? NSUserDefaults.standardUserDefaults().connectionHistory.count + 1 : 1
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 65 : 44
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		if indexPath.section == 0 {
			let connections = NSUserDefaults.standardUserDefaults().connectionHistory
			if indexPath.row == connections.count {
				cell.textLabel?.text = "Add an API..."
				cell.textLabel?.textColor = view.tintColor
			} else {
				let connection = NSUserDefaults.standardUserDefaults().connectionHistory[indexPath.row]
				cell.textLabel?.text = connection.absoluteString
				cell.textLabel?.lineBreakMode = .ByTruncatingMiddle
				cell.accessoryType = connection == connections.first ? .Checkmark : .None
			}
		} else if indexPath.section == 1 {
			cell.textLabel?.font = UIFont.systemFontOfSize(15)
			if let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String, appBuild = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
				cell.textLabel?.text = "\(appVersion) (\(appBuild))"
			}
		} else {
			let button = UIButton(type: .System)
			button.setTitle("Zetta Discuss", forState: .Normal)
			button.addTarget(self, action: "supportButtonTapped", forControlEvents: .TouchUpInside)
			button.contentHorizontalAlignment = .Left
			button.contentEdgeInsets = UIEdgeInsetsMake(0, tableView.layoutMargins.left, 0, tableView.layoutMargins.right)
			button.translatesAutoresizingMaskIntoConstraints = false
			cell.contentView.addSubview(button)
			button.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(cell.contentView)
			}
		}
		return cell
    }
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return indexPath.section == 0
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
	
	// MARK: - button actions
	
	@objc private func doneButtonTapped() {
		//if the selected connection changed, let the delegate know
		if NSUserDefaults.standardUserDefaults().connectionHistory.first != previousURL {
			delegate?.selectedConnectionChanged()
		}
		
		presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@objc private func supportButtonTapped() {
		guard let url = NSURL(string: "https://groups.google.com/forum/#!forum/zetta-discuss") else { return }
		let controller = SFSafariViewController(URL: url)
		presentViewController(controller, animated: true, completion: nil)
	}
	
}