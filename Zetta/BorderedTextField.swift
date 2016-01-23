//
//  EditProfileTextField.swift
//  Songline
//
//  Created by Ben Packard on 7/29/15.
//  Copyright (c) 2015 Songline. All rights reserved.
//

import UIKit

class BorderedTextField: UIView {
	
	let textField = UITextField()
	private let fieldBackground = UIView()
	private let overLine = UIView()
	private let underLine = UIView()

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
		fieldBackground.backgroundColor = UIColor.whiteColor()
		overLine.backgroundColor = UIColor.tableViewSeparatorColor()
		underLine.backgroundColor = overLine.backgroundColor
		
		for view in [fieldBackground, textField, overLine, underLine] {
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		setNeedsUpdateConstraints()
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			fieldBackground.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(self)
			}
			
			textField.snp_makeConstraints { (make) -> Void in
				make.left.right.equalTo(self).inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 10))
				make.top.bottom.equalTo(self)
			}
			
			overLine.snp_makeConstraints { (make) -> Void in
				make.top.left.right.equalTo(fieldBackground)
				make.height.equalTo(0.5)
			}
			
			underLine.snp_makeConstraints { (make) -> Void in
				make.bottom.left.right.equalTo(fieldBackground)
				make.height.equalTo(0.5)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}

}
