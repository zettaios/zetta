//
//  SettingsViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/23/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
	
	private let supportEmail = "linksupport@apigee.com"
	
	convenience init() {
		self.init(style: .Grouped)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Settings"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonTapped")
		
		tableView.backgroundColor = UIColor.whiteColor()
		tableView.separatorStyle = .None
		
		let controller = ConnectionViewController()
		navigationController?.pushViewController(controller, animated: false)
    }

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "Connection Settings".uppercaseString
		case 1: return "Build Version".uppercaseString
		case 2: return "Support".uppercaseString
		default: return nil
		}
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 65 : 44
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = BorderedCell(style: .Value1, reuseIdentifier: nil)
			cell.textLabel?.text = "Connect using"
//			cell.detailTextLabel?.text = ""
			cell.accessoryType = .DisclosureIndicator
			return cell
		} else if indexPath.section == 1 {
			let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
			cell.textLabel?.font = UIFont.systemFontOfSize(15)
			if let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String, appBuild = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
				cell.textLabel?.text = "\(appVersion) (\(appBuild))"
			}
			return cell
		} else {
			let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
			let button = UIButton(type: .System)
			button.setTitle(supportEmail, forState: .Normal)
			button.addTarget(self, action: "emailSupportButtonTapped", forControlEvents: .TouchUpInside)
			button.contentHorizontalAlignment = .Left
			button.contentEdgeInsets = UIEdgeInsetsMake(0, tableView.layoutMargins.left, 0, tableView.layoutMargins.right)
			button.translatesAutoresizingMaskIntoConstraints = false
			cell.contentView.addSubview(button)
			button.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(cell.contentView)
			}
			return cell
		}
    }
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return indexPath.section == 0
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let controller = ConnectionViewController()
		navigationController?.pushViewController(controller, animated: true)
	}
	
	// MARK: - button actions
	
	@objc private func doneButtonTapped() {
		presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@objc private func emailSupportButtonTapped() {
		print("email")
	}
	
}
