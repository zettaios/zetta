//
//  PropertyCell.swift
//  Zetta
//
//  Created by Ben Packard on 2/19/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class PropertyCell: UITableViewCell {

	private var constraintsAdded = false
	
	override var backgroundColor: UIColor? {
		didSet {
			let appropriateColor = backgroundColor?.isLight != false ? UIColor.appDarkGrayColor() : UIColor.whiteColor()
			titleLabel.textColor = appropriateColor
			subtitleLabel.textColor = appropriateColor
		}
	}
	
	lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.whiteColor()
		label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightUltraLight)
		label.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.whiteColor()
		label.font = UIFont.boldSystemFontOfSize(18)
		label.textAlignment = .Right
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.8
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		for view in [titleLabel, subtitleLabel] {
			view.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(view)
		}
		
		setNeedsUpdateConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			titleLabel.snp_makeConstraints { (make) -> Void in
				make.left.equalTo(contentView).offset(16)
				make.top.bottom.equalTo(contentView)
			}
			
			subtitleLabel.snp_makeConstraints { (make) -> Void in
				make.centerY.equalTo(contentView)
				make.right.equalTo(contentView).offset(-16)
				make.left.greaterThanOrEqualTo(titleLabel.snp_right).offset(10)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		titleLabel.text = nil
		subtitleLabel.text = nil
		accessoryView = nil
	}
	
}
