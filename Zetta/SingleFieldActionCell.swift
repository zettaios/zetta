//
//  SingleFieldActionCell.swift
//  Zetta
//
//  Created by Ben Packard on 2/17/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class SingleFieldActionCell: UITableViewCell {

	private var constraintsAdded = false
	
	lazy var textField: UITextField =  {
		let textField = UITextField()
		textField.font = UIFont.systemFontOfSize(18)
		textField.returnKeyType = .Go
		return textField
	}()
	
	lazy var goButton: UIButton = {
		let button = UIButton.deviceActionButton(title: "Go")
		button.setContentHuggingPriority(1000, forAxis: .Horizontal)
		button.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
		return button
	}()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.textField, self.goButton])
		stack.axis = .Horizontal
		stack.spacing = 10
		stack.layoutMarginsRelativeArrangement = true
		stack.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
		return stack
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

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
			
			textField.snp_makeConstraints { (make) -> Void in
				make.height.greaterThanOrEqualTo(38)
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
