//
//  MultipleFieldsActionCell.swift
//  Zetta
//
//  Created by Ben Packard on 2/17/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class MultipleFieldsActionCell: UITableViewCell {

	weak var delegate: ActionCellDelegate?
	private let textFields: [UITextField]
	private var constraintsAdded = false
	
	lazy var goButton: UIButton = {
		let button = UIButton.deviceActionButton(title: "Go")
		button.addTarget(self, action: "buttonTapped", forControlEvents: .TouchUpInside)
		return button
	}()
	
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
			textField.textColor = UIColor.appDarkGrayColor()
			textField.placeholder = fieldName.stringByAppendingString("...")
			textField.returnKeyType = .Go
			textField.autocapitalizationType = .None
			textField.autocorrectionType = .No
			return textField
		})
		
		super.init(style: .Default, reuseIdentifier: nil)
		
		for textField in self.textFields {
			textField.delegate = self
		}
		
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
			
			goButton.snp_makeConstraints { (make) -> Void in
				make.width.greaterThanOrEqualTo(goButton.snp_height).multipliedBy(1.5)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		for textField in textFields {
			textField.text = nil
		}
		delegate = nil
	}
	
	@objc private func buttonTapped() {
		let strings = textFields.map{ $0.text }
		delegate?.actionCell(self, didSubmitFields: strings)
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		goButton.backgroundColor = tintColor
		goButton.tintColor = tintColor.isLight ? UIColor.blackColor() : UIColor.whiteColor()
	}
	
}

extension MultipleFieldsActionCell: UITextFieldDelegate {
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		buttonTapped()
		return false
	}
	
}