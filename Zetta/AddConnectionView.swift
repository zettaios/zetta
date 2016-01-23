//
//  AddConnectionView.swift
//  Zetta
//
//  Created by Ben Packard on 1/23/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class AddConnectionView: UIView {

	var urlField: UITextField {
		return urlBorderedField.textField
	}
	
	private lazy var urlBorderedField: BorderedTextField = {
		let urlField = BorderedTextField()
		urlField.textField.placeholder = "Server URL"
		urlField.textField.clearButtonMode = .WhileEditing
		urlField.textField.autocapitalizationType = .None
		urlField.textField.autocorrectionType = .No
		urlField.textField.keyboardType = .URL
		return urlField
	}()
	
	private var constraintsAdded = false
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		
		
		backgroundColor = UIColor.groupTableViewBackgroundColor()
		
		for view in [urlBorderedField] {
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		setNeedsUpdateConstraints()
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			urlBorderedField.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(self).offset(30)
				make.left.right.equalTo(self)
				make.height.equalTo(65)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}

}
