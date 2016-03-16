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
	private var constraintsAdded = false
	
	lazy var textField: UITextField =  {
		let textField = UITextField()
		textField.font = UIFont.systemFontOfSize(18)
		textField.returnKeyType = .Go
		textField.delegate = self
		textField.textColor = UIColor.appDarkGrayColor()
		textField.autocapitalizationType = .None
		textField.autocorrectionType = .No
		return textField
	}()
	
	lazy var goButton: UIButton = {
		let button = UIButton.deviceActionButton(title: "Go")
		button.setContentHuggingPriority(1000, forAxis: .Horizontal)
		button.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
		button.addTarget(self, action: "buttonTapped", forControlEvents: .TouchUpInside)
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
			
			goButton.snp_makeConstraints { (make) -> Void in
				make.width.greaterThanOrEqualTo(goButton.snp_height).multipliedBy(1.5)
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
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		goButton.backgroundColor = tintColor
		goButton.tintColor = tintColor.isLight ? UIColor.blackColor() : UIColor.whiteColor()
	}
	
}

extension SingleFieldActionCell: UITextFieldDelegate {
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		buttonTapped()
		return false
	}
	
}
