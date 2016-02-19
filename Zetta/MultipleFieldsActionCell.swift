//
//  MultipleFieldsActionCell.swift
//  Zetta
//
//  Created by Ben Packard on 2/17/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class MultipleFieldsActionCell: UITableViewCell {

	private let textFields: [UITextField]
	private var constraintsAdded = false
	
	let goButton = UIButton.deviceActionButton(title: "Go")
	
	private lazy var stack: UIStackView = {
		var stackedViews: [UIView] = self.textFields
		stackedViews.append(self.goButton)
		let stack = UIStackView(arrangedSubviews: stackedViews)
		stack.axis = .Vertical
		stack.spacing = 15
		stack.layoutMarginsRelativeArrangement = true
		stack.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
		return stack
	}()
	
	init(fieldNames: [String]) {
		self.textFields = fieldNames.map({ (fieldName) -> UITextField in
			let textField = UITextField()
			textField.font = UIFont.systemFontOfSize(18)
			textField.placeholder = fieldName.stringByAppendingString("...")
			textField.returnKeyType = .Go
			return textField
		})
		
		super.init(style: .Default, reuseIdentifier: nil)
		
		stack.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(stack)
		
		setNeedsUpdateConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}

	
	override func updateConstraints() {
		if !constraintsAdded {
			stack.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(contentView)
			}
			
			for textField in textFields {
				textField.snp_makeConstraints { (make) -> Void in
					make.height.greaterThanOrEqualTo(38)
				}
			}
			
			goButton.snp_makeConstraints { (make) -> Void in
				make.height.greaterThanOrEqualTo(38)
				make.width.greaterThanOrEqualTo(goButton.snp_height).multipliedBy(1.5)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
	}
	
}
