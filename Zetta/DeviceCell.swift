//
//  DeviceCell.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
	
	lazy var deviceImageView: UIImageView = {
		let deviceImageView = UIImageView()
		deviceImageView.contentMode = .ScaleAspectFit
		return deviceImageView
	}()

	lazy var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.textColor = UIColor.appMediumGrayColor()
		titleLabel.font = UIFont.systemFontOfSize(13)
		return titleLabel
	}()
	
	lazy var subtitleLabel: UILabel = {
		let subtitleLabel = UILabel()
		subtitleLabel.textColor = UIColor.appDarkGrayColor()
		subtitleLabel.font = UIFont.systemFontOfSize(16)
		return subtitleLabel
	}()
	
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
		for view in [deviceImageView, titleLabel, subtitleLabel] {
			view.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(view)
		}
		
		self.accessoryType = .DisclosureIndicator
		
		setNeedsUpdateConstraints()
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
		
		deviceImageView.tintColor = UIColor.appDefaultDeviceTintColor()
		deviceImageView.pin_cancelImageDownload() //prevent late loading
		deviceImageView.image = nil
	}
	
}
