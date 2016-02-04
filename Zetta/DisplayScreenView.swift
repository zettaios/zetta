//
//  DisplayScreenView.swift
//  Zetta
//
//  Created by Ben Packard on 2/4/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class DisplayScreenView: UIView {

	// MARK: - subviews
	
	private var constraintsAdded = false
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.alwaysBounceVertical = false
		return scrollView
	}()
	
	private let contentView = UIView()
	
	private lazy var messageBackground: UIView = {
		let messageBackground = UIView()
		messageBackground.backgroundColor = UIColor.blackColor()
		return messageBackground
	}()
	
	lazy var messageLabel: UILabel = {
		let messageLabel = UILabel()
		messageLabel.text = "message"
		messageLabel.font = UIFont(name: "CourierNewPSMT", size: 18)
		messageLabel.textColor = UIColor(red:0.271,  green:0.949,  blue:0.224, alpha:1)
		messageLabel.numberOfLines = 0
		return messageLabel
	}()
	
	private lazy var instructionsLabel: UILabel = {
		let instructionsLabel = UILabel()
		let string = "Type a new message below and tap DONE."
		let attributedString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(13)])
		let range = (string as NSString).rangeOfString("DONE")
		attributedString.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(13)], range: range)
		instructionsLabel.attributedText = attributedString
		instructionsLabel.textColor = UIColor.appMediumGrayColor()
		instructionsLabel.textAlignment = .Center
		instructionsLabel.adjustsFontSizeToFitWidth = true
		return instructionsLabel
	}()
	
	private lazy var newMessageBackground: UIView = {
		let newMessageBackground = UIView()
		newMessageBackground.backgroundColor = UIColor.whiteColor()
		return newMessageBackground
	}()
	
	lazy var newMessageField: UITextField = {
		let newMessageField = UITextField()
		newMessageField.textColor = UIColor(red:0.290,  green:0.290,  blue:0.290, alpha:1)
		newMessageField.font = self.messageLabel.font
		newMessageField.placeholder = "New message..."
		newMessageField.clearButtonMode = .WhileEditing
		newMessageField.returnKeyType = .Done
		return newMessageField
	}()
	
	private let newMessageOverLine = UIView.hairline()
	private let newMessageUnderLine = UIView.hairline()
	
	// MARK: - initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
		
		backgroundColor = UIColor.groupTableViewBackgroundColor()
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(scrollView)
		
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)
		
		for view in [messageBackground, messageLabel, instructionsLabel, newMessageBackground, newMessageField, newMessageOverLine, newMessageUnderLine] {
			view.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(view)
		}
		
		setNeedsUpdateConstraints()
	}
	
	// MARK: - layout
	
	override func updateConstraints() {
		if !constraintsAdded {
			scrollView.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(self)
			}
			
			contentView.snp_makeConstraints { (make) -> Void in
				make.edges.width.equalTo(scrollView)
			}
			
			messageBackground.snp_makeConstraints { (make) -> Void in
				make.top.left.right.equalTo(contentView).inset(UIEdgeInsets(top: 25, left: 15, bottom: 0, right: 15))
			}
			
			messageLabel.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(messageBackground).inset(15)
			}
			
			instructionsLabel.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(messageBackground.snp_bottom).offset(25)
				make.left.right.equalTo(contentView).inset(20)
			}
			
			newMessageBackground.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(instructionsLabel.snp_bottom).offset(15)
				make.left.right.equalTo(contentView)
				make.bottom.equalTo(contentView).inset(40)
			}
			
			newMessageField.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(newMessageBackground).inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 10)) //allow for the clear button
				make.height.equalTo(80)
			}
			
			newMessageOverLine.snp_makeConstraints { (make) -> Void in
				make.top.left.right.equalTo(newMessageBackground)
				make.height.equalTo(0.5)
			}
			
			newMessageUnderLine.snp_makeConstraints { (make) -> Void in
				make.bottom.left.right.equalTo(newMessageBackground)
				make.height.equalTo(0.5)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	// MARK: - keyboard management
	
	@objc private func keyboardWillShow(notification: NSNotification) {
		if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size.height {
			scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
			scrollView.scrollIndicatorInsets = scrollView.contentInset
		}
	}
	
	@objc private func keyboardWillHide(notification: NSNotification) {
		self.scrollView.contentInset = UIEdgeInsetsZero
		self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
	}

}
