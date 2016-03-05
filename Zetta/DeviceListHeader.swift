//
//  DeviceListHeader.swift
//  Zetta
//
//  Created by Ben Packard on 3/4/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class DeviceListHeader: UIView {

	private var constraintsAdded = false
	
	private lazy var colorBox: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 2
		return view
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFontOfSize(17)
		label.textColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
		return label
	}()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.colorBox, self.titleLabel])
		stack.spacing = 10
		stack.alignment = .Center
		stack.layoutMarginsRelativeArrangement = true
		stack.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
		return stack
	}()
	
	init(title: String?, color: UIColor?) {
		super.init(frame: CGRect.zero)

		backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
		titleLabel.text = title
		colorBox.backgroundColor = color
		colorBox.hidden = color == nil
		
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
			
			colorBox.snp_makeConstraints { (make) -> Void in
				make.size.equalTo(self.snp_height).offset(-10)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}

}
