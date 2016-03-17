//
//  EventsLogViewController.swift
//  Zetta
//
//  Created by Ben Packard on 3/16/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit

class EventsLogViewController: UITableViewController {
	private let eventLogs: [ZIKLogStreamEntry]
	private let cellIdentifier = "Cell"
	
	private lazy var dateFormatter: NSDateFormatter = {
		let formatter = NSDateFormatter()
		formatter.dateStyle = .ShortStyle
		formatter.timeStyle = .MediumStyle
		return formatter
	}()
	
	init(eventLogs: [ZIKLogStreamEntry]) {
		self.eventLogs = eventLogs
		super.init(style: .Plain)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Events"
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60
		tableView.tableFooterView = UIView()
		tableView.allowsSelection = false
		tableView.registerClass(EventLogCell.self, forCellReuseIdentifier: cellIdentifier)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}

    // MARK: - table view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventLogs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? EventLogCell else { return UITableViewCell() }
		
		let log = eventLogs[indexPath.row]
		let valueStrings = log.inputs.flatMap { (input) -> String? in
			if let name = input["name"] as? String, value = input["value"] as? String {
				return "\(name): \(value)"
			}
			return nil
		}
		let inputString = valueStrings.joinWithSeparator(", ")
		let logString = [log.transition, inputString.nonEmptyTrimmed()].flatMap({ $0 }).joinWithSeparator(" - ")
		cell.titleLabel.text = logString
		
		let date = NSDate(timeIntervalSince1970: log.timestamp.doubleValue / 1000)
		cell.subtitleLabel.text = dateFormatter.stringFromDate(date)
        return cell
    }
}
