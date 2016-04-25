//
//  BillboardStateCell.swift
//  Zetta
//
//  Created by Ben Packard on 4/24/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class BillboardStateCell: UITableViewCell {
	private var constraintsAdded = false
	
	lazy var iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .ScaleAspectFit
		return imageView
	}()
	
	lazy var underLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFontOfSize(24)
//		label.textColor = self.tintColor
		label.textAlignment = .Center
		label.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
		return label
	}()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.iconImageView, self.underLabel])
		stack.axis = .Vertical
		stack.spacing = 10
		stack.layoutMarginsRelativeArrangement = true
		stack.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 20)
		return stack
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		stack.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(stack)
		stack.snp_makeConstraints { (make) -> Void in
			make.edges.equalTo(contentView)
		}
		
		setNeedsUpdateConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
		
	override func updateConstraints() {
		if !constraintsAdded {
			
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		iconImageView.sd_cancelCurrentImageLoad() //prevent late loading
		iconImageView.image = nil
		underLabel.text = nil
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()

		iconImageView.tintColor = tintColor
		underLabel.textColor = tintColor
	}	
}
