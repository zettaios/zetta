//
//  DeviceViewController.swift
//  Zetta
//
//  Created by Ben Packard on 2/12/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit

class DeviceViewController: UITableViewController {

	private let device: ZIKDevice
	private let noFieldsActionCellIdentifier = "No Fields Action Cell"
	private let singleFieldActionCellIdentifier = "Single Field Action Cell"
	
	init(device: ZIKDevice) {
		self.device = device
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = device.name ?? "Unnamed Device"
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60
		tableView.tableFooterView = UIView()
		tableView.registerClass(NoFieldsActionCell.self, forCellReuseIdentifier: noFieldsActionCellIdentifier)
		tableView.registerClass(SingleFieldActionCell.self, forCellReuseIdentifier: singleFieldActionCellIdentifier)
		tableView.allowsSelection = false
		tableView.keyboardDismissMode = .OnDrag
    }

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "Streams"
		case 1: return "Actions"
		case 2: return "Properties"
		case 3: return "Events"
		default: return nil
		}
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0: return 1
		case 1: return device.transitions.count
		case 2: return device.properties.count
		case 3: return 1
		default: return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
		cell.textLabel?.font = UIFont.systemFontOfSize(17)
		cell.detailTextLabel?.font = UIFont.systemFontOfSize(17)
		cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
		cell.detailTextLabel?.minimumScaleFactor = 0.8
		
		if indexPath.section == 1 {
			return actionCellForIndexPath(indexPath)
		} else if indexPath.section == 2 {
			guard let properties = device.properties as? [String: AnyObject] else { return cell }
			
			let key = Array(properties.keys)[indexPath.row]
			cell.textLabel?.text = key
			
			if let value = properties[key] as? String {
				cell.detailTextLabel?.text = value
			}
		} else {
			cell.detailTextLabel?.text = "to follow..."
		}
		
        return cell
    }
	
	private func fieldNamesForTransition(transition: ZIKTransition) -> [String] {
		var fieldNames = [String]()
		if let fields = transition.fields as? [[String: AnyObject]] {
			for field in fields {
				if let type = field["type"] as? String where type != "hidden", let name = field["name"] as? String {
					fieldNames.append(name)
				}
			}
		}
		return fieldNames
	}
	
	private func actionCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let transitions = device.transitions as? [ZIKTransition] else { return UITableViewCell() }

		let transition = transitions[indexPath.row]
		let fieldNames = fieldNamesForTransition(transition)
		
		if fieldNames.isEmpty {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(noFieldsActionCellIdentifier) as? NoFieldsActionCell else { return UITableViewCell() }
			cell.titleLabel.text = transition.name
			return cell
		} else if fieldNames.count == 1 {
			guard let cell = tableView.dequeueReusableCellWithIdentifier(singleFieldActionCellIdentifier) as? SingleFieldActionCell else { return UITableViewCell() }
			cell.textField.placeholder = fieldNames.first?.stringByAppendingString("...")
			if transition.name != fieldNames.first {
				cell.goButton.setTitle(transition.name, forState: .Normal)
			}
			return cell
		} else {
			let cell = MultipleFieldsActionCell(fieldNames: fieldNames)
			if transition.name != fieldNames.first {
				cell.goButton.setTitle(transition.name, forState: .Normal)
			}
			return cell
		}
	}
	
}
