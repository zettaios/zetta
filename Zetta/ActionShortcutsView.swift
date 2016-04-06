//
//  ActionShortcutsView.swift
//  Zetta
//
//  Created by Ben Packard on 4/6/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class ActionShortcutsView: UIView {
	private var constraintsAdded = false
	
	lazy var deviceLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = UIColor(white: 0.97, alpha: 1)
		label.font = UIFont.boldSystemFontOfSize(17)
		label.textAlignment = .Center
		return label
	}()
	
	lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.alwaysBounceVertical = false
		tableView.tableFooterView = UIView()
//		tableView.backgroundColor = self.backgroundColor
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60
		tableView.allowsSelection = false
		return tableView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		for view in [deviceLabel, tableView] {
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		setNeedsUpdateConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			tableView.snp_makeConstraints { (make) -> Void in
				make.left.right.bottom.equalTo(self)
				make.height.lessThanOrEqualTo(self).multipliedBy(0.5)
//				make.height.equalTo(device.nonHiddenTransitions.count * 60).priorityHigh()
			}
			
			deviceLabel.snp_makeConstraints { (make) -> Void in
				make.left.right.equalTo(tableView)
				make.bottom.equalTo(tableView.snp_top)
				make.height.equalTo(44)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
}
