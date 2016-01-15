//
//  NoServerView.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import SnapKit

class ConnectionView: UIView {

	lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.color = self.tintColor
		spinner.hidesWhenStopped = true
		return spinner
	}()
	
	lazy var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.textAlignment = .Center
		titleLabel.numberOfLines = 0
		return titleLabel
	}()
	
	lazy var subtitleLabel: UILabel = {
		let subtitleLabel = UILabel()
		subtitleLabel.textAlignment = .Center
		subtitleLabel.numberOfLines = 0
		return subtitleLabel
	}()
	
	lazy var settingsButton: UIButton = {
		let settingsButton = UIButton(type: .System)
		settingsButton.setTitle("Open Settings", forState: .Normal)
		settingsButton.hidden = true
		return settingsButton
	}()
	
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
		backgroundColor = UIColor.whiteColor()
		
		for view in [spinner, titleLabel, subtitleLabel, settingsButton] {
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		setNeedsUpdateConstraints()
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			spinner.snp_makeConstraints { (make) -> Void in
				make.centerX.equalTo(self)
				make.bottom.equalTo(titleLabel.snp_top).offset(-30)
			}
			
			titleLabel.snp_makeConstraints { (make) -> Void in
				make.bottom.equalTo(subtitleLabel.snp_top).offset(-10)
				make.left.right.equalTo(self).inset(40)
			}
			
			subtitleLabel.snp_makeConstraints { (make) -> Void in
				make.centerY.equalTo(self)
				make.left.right.equalTo(titleLabel)
			}
			
			settingsButton.snp_makeConstraints { (make) -> Void in
				make.top.equalTo(subtitleLabel.snp_bottom).offset(20)
				make.centerX.equalTo(self)
				make.height.greaterThanOrEqualTo(44)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}

}
