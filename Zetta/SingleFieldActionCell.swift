//
//  SingleFieldActionCell.swift
//  Zetta
//
//  Created by Ben Packard on 2/17/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class SingleFieldActionCell: UITableViewCell {

	weak var delegate: ActionCellDelegate?
	private var fieldName: String
	private var constraintsAdded = false
	
	override var backgroundColor: UIColor? {
		didSet {
			let appropriateColor = backgroundColor?.isLight != false ? UIColor.appDarkGrayColor() : UIColor.whiteColor()
			textField.textColor = appropriateColor
			let attributes = [NSForegroundColorAttributeName: appropriateColor, NSFontAttributeName: UIFont.systemFontOfSize(18, weight: UIFontWeightUltraLight)]
			textField.attributedPlaceholder = NSAttributedString(string: "\(fieldName)...", attributes: attributes)
		}
	}
	
	override var tintColor: UIColor? {
		didSet {
			goButton.backgroundColor = tintColor
			goButton.setTitleColor(tintColor?.isLight != false ? backgroundColor : UIColor.whiteColor(), forState: .Normal)
		}
	}
	
	lazy var textField: UITextField =  {
		let textField = UITextField()
		textField.font = UIFont.systemFontOfSize(18)
		textField.returnKeyType = .Go
		textField.delegate = self
		textField.autocapitalizationType = .None
		textField.autocorrectionType = .No
		return textField
	}()
	
	lazy var goButton: UIButton = {
		let button = UIButton.deviceActionButton(title: "Go")
		button.setContentHuggingPriority(1000, forAxis: .Horizontal)
		button.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
		button.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
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
	
	init(fieldName: String) {
		self.fieldName = fieldName
		
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
			
			goButton.snp_makeConstraints { (make) -> Void in
				make.height.equalTo(35.5)
				make.width.greaterThanOrEqualTo(goButton.snp_height)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		textField.text = nil
		delegate = nil
	}
	
	@objc private func buttonTapped() {
		textField.resignFirstResponder()
		delegate?.actionCell(self, didSubmitFields: [textField.text])
		textField.text = nil
	}
	
}

extension SingleFieldActionCell: UITextFieldDelegate {
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		buttonTapped()
		return false
	}
	
}
