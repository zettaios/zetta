//
//  BillboardCell.swift
//  Zetta
//
//  Created by Ben Packard on 3/18/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class BillboardCell: UITableViewCell {

	let defaultFontSize: CGFloat = 150
	private var constraintsAdded = false
	
	lazy var overLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFontOfSize(18)
		label.textAlignment = .Center
		label.textColor = self.tintColor
		return label
	}()
	
	lazy var mainLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFontOfSize(self.defaultFontSize)
		label.adjustsFontSizeToFitWidth = true
		label.textAlignment = .Center
		label.textColor = self.tintColor
		return label
	}()
	
	lazy var underLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFontOfSize(18)
		label.textAlignment = .Center
		label.textColor = self.tintColor
		return label
	}()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.overLabel, self.mainLabel, self.underLabel])
		stack.axis = .Vertical
		stack.spacing = 10
//		stack.layoutMarginsRelativeArrangement = true
//		stack.layoutMargins = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
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
//				make.edges.equalTo(contentView)
				make.center.equalTo(contentView)
				make.left.right.equalTo(contentView).inset(40)
				make.top.greaterThanOrEqualTo(contentView).offset(40)
				make.bottom.lessThanOrEqualTo(contentView).offset(-40)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		for label in [overLabel, mainLabel, underLabel] {
			label.textColor = tintColor
		}
	}
	
}
