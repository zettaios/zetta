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
	
	let dismissZone = UIView()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.dismissZone, self.deviceLabel, self.tableView])
		stack.axis = .Vertical
		return stack
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		stack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stack)
		
		setNeedsUpdateConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			stack.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(self)
			}
			
			tableView.snp_makeConstraints { (make) -> Void in
				make.height.lessThanOrEqualTo(self).multipliedBy(0.5)
			}
			
			deviceLabel.snp_makeConstraints { (make) -> Void in
				make.height.equalTo(44)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
}
