//
//  BorderedCell.swift
//  Zetta
//
//  Created by Ben Packard on 1/23/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import SnapKit

class BorderedCell: UITableViewCell {

	private let top = UIView.hairline()
	private let bottom = UIView.hairline()
	
	private var constraintsAdded = false
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {

		for line in [top, bottom] {
			line.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(line)
		}
		
		setNeedsUpdateConstraints()
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			top.snp_makeConstraints { (make) -> Void in
				make.top.left.right.equalTo(self)
				make.height.equalTo(0.5)
			}
			
			bottom.snp_makeConstraints { (make) -> Void in
				make.bottom.left.right.equalTo(self)
				make.height.equalTo(0.5)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		let topColor = top.backgroundColor
		let bottomColor = bottom.backgroundColor
		
		super.setSelected(selected, animated: animated)
		
		top.backgroundColor = topColor
		bottom.backgroundColor = bottomColor
	}
	
	override func setHighlighted(highlighted: Bool, animated: Bool) {
		let topColor = top.backgroundColor
		let bottomColor = bottom.backgroundColor
		
		super.setHighlighted(highlighted, animated: animated)
		
		top.backgroundColor = topColor
		bottom.backgroundColor = bottomColor
	}
	
}
