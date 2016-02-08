//
//  ColorPickerCell.swift
//  Zetta
//
//  Created by Ben Packard on 2/7/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class ColorPickerCell: UICollectionViewCell {
	
	var showCheckmark = false {
		didSet {
			checkmark.hidden = !showCheckmark
		}
	}
	
	private var constraintsAdded = false
	
	private lazy var checkmark: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "Checkmark")?.imageWithRenderingMode(.AlwaysTemplate)
		imageView.tintColor = UIColor(white: 1, alpha: 0.75)
		imageView.contentMode = .ScaleAspectFit
		imageView.hidden = true
		return imageView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		checkmark.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(checkmark)
		
		setNeedsUpdateConstraints()
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			checkmark.snp_makeConstraints { (make) -> Void in
				make.center.equalTo(contentView)
				make.width.equalTo(20)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}
	
	override var highlighted: Bool {
		willSet(newValue) {
			if newValue == true {
				self.alpha = 0.5
			} else {
				UIView.animateWithDuration(0.5, animations: { () -> Void in
					self.alpha = 1
				})
			}
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()

		showCheckmark = false
	}
	
}
