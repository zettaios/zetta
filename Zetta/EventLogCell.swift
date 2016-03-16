//
//  EventLogCell.swift
//  Zetta
//
//  Created by Ben Packard on 3/16/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class EventLogCell: UITableViewCell {

	private var constraintsAdded = false
	
	lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFontOfSize(16)
		label.textColor = UIColor.appDarkGrayColor()
		label.numberOfLines = 0
		label.font = UIFont.systemFontOfSize(12)
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.appMediumGrayColor()
		label.font = UIFont.systemFontOfSize(12)
		return label
	}()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
		stack.axis = .Vertical
		stack.spacing = 3
		stack.layoutMarginsRelativeArrangement = true
		stack.layoutMargins = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
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
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
	}
	
}
