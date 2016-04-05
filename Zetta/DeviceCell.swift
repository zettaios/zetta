//
//  DeviceCell.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
	
	private var constraintsAdded = false
	
	lazy var deviceImageView: UIImageView = {
		let deviceImageView = UIImageView()
		deviceImageView.contentMode = .ScaleAspectFit
		deviceImageView.layer.cornerRadius = 3
		return deviceImageView
	}()

	lazy var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
		return titleLabel
	}()
	
	lazy var subtitleLabel: UILabel = {
		let subtitleLabel = UILabel()
		subtitleLabel.font = UIFont.boldSystemFontOfSize(16)
		return subtitleLabel
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		for view in [deviceImageView, titleLabel, subtitleLabel] {
			view.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(view)
		}
		
		layoutMargins = UIEdgeInsetsZero
		
		setNeedsUpdateConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			deviceImageView.snp_makeConstraints { (make) -> Void in
				make.left.equalTo(contentView).offset(20)
				make.top.bottom.equalTo(contentView).inset(16)
				make.width.equalTo(deviceImageView.snp_height)
			}
			
			titleLabel.snp_makeConstraints { (make) -> Void in
				make.left.equalTo(deviceImageView.snp_right).offset(20)
				make.right.lessThanOrEqualTo(contentView).offset(-20)
				make.bottom.equalTo(subtitleLabel.snp_top).offset(-4)
			}
			
			subtitleLabel.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(contentView.snp_centerY)
				make.left.equalTo(titleLabel)
				make.right.lessThanOrEqualTo(contentView).offset(-20)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		deviceImageView.sd_cancelCurrentImageLoad() //prevent late loading
		
		//remove long presses to avoid double-fires when recycled
		if let recognizers = contentView.gestureRecognizers {
			for recognizer in recognizers {
				contentView.removeGestureRecognizer(recognizer)
			}
		}
	}
}
