//
//  NoFieldsActionCell.swift
//  Zetta
//
//  Created by Ben Packard on 2/17/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

protocol ActionCellDelegate: class {
	func actionCell(cell: UITableViewCell, didSubmitFields fields: [String?])
}

class NoFieldsActionCell: UITableViewCell {

	weak var delegate: ActionCellDelegate?
	private var constraintsAdded = false
	
	override var backgroundColor: UIColor? {
		didSet {
			let appropriateColor = backgroundColor?.isLight == true ? UIColor.appDarkGrayColor() : UIColor.whiteColor()
			titleLabel.textColor = appropriateColor
		}
	}
	
	override var tintColor: UIColor? {
		didSet {
			goButton.backgroundColor = tintColor
			goButton.tintColor = self.backgroundColor
		}
	}
	
	lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.whiteColor()
		label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightUltraLight)
		return label
	}()
	
	lazy var goButton: UIButton = {
		let button = UIButton.deviceActionButton(title: "Go")
		button.setContentHuggingPriority(1000, forAxis: .Horizontal)
		button.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
		button.addTarget(self, action: "buttonTapped", forControlEvents: .TouchUpInside)
		return button
	}()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.titleLabel, self.goButton])
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
				make.height.equalTo(35.5)
				make.width.greaterThanOrEqualTo(goButton.snp_height)
			}
			
			constraintsAdded = true
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		titleLabel.text = nil
		delegate = nil
	}
	
	@objc private func buttonTapped() {
		delegate?.actionCell(self, didSubmitFields: [String?]())
	}
}
