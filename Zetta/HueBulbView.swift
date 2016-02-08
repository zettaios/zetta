//
//  HueBulbView.swift
//  Zetta
//
//  Created by Ben Packard on 2/5/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class HueBulbView: UIView {

	private var constraintsAdded = false
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.alwaysBounceVertical = false
		return scrollView
	}()
	
	lazy var lightBulb: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .ScaleAspectFit
		imageView.image = UIImage(named: "Light Bulb")
		return imageView
	}()
	
	private let loopLabel = UILabel.devicePropertyLabel(text: "Loop")
	private let loopSwitchPlaceholder = UIView()
	let loopSwitch = UISwitch()
	
	private let blinkLabel = UILabel.devicePropertyLabel(text: "Blink")
	let blinkSwitchPlaceholder = UIView()
	let blinkSwitch = UISwitch()
	
	private let brightnessLabel = UILabel.devicePropertyLabel(text: "Brightness")
	
	lazy var brightnessSlider: UISlider = {
		let slider = UISlider()
		slider.minimumValueImage = UIImage(named: "Minimum Brightness")
		slider.maximumValueImage = UIImage(named: "Maximum Brightness")
		return slider
	}()
	
	private lazy var brightnessBackground: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(white: 0.975, alpha: 1)
		return view
	}()
	
	private let colorLabel = UILabel.devicePropertyLabel(text: "Color Picker")
	let colorPicker = ColorPicker()
	
	//stacks
	
	private lazy var bulbStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.loopSwitchPlaceholder, self.lightBulb, self.blinkSwitchPlaceholder])
		stack.axis = .Horizontal
		stack.spacing = 0
		return stack
	}()
	
	private lazy var brightnessStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.brightnessLabel, self.brightnessSlider])
		stack.axis = .Vertical
		stack.spacing = 10
		stack.layoutMarginsRelativeArrangement = true
		stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		return stack
	}()
	
	private lazy var colorStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.colorLabel, self.colorPicker])
		stack.axis = .Vertical
		stack.spacing = 10
		return stack
	}()
	
	private lazy var mainStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.bulbStack, self.brightnessStack, self.colorStack])
		stack.axis = .Vertical
		stack.spacing = 40
		stack.layoutMarginsRelativeArrangement = true
		stack.layoutMargins = UIEdgeInsets(top: 30, left: 0, bottom: 20, right: 0)
		return stack
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
		backgroundColor = UIColor.whiteColor()
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(scrollView)
		
		mainStack.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(mainStack)
		
		//uiswitch is not resizeable, so a transform is used
		let switchScale: CGFloat = UIScreen.mainScreen().bounds.size.width * 0.004 //equates to 1.5x on an iPhone 6
		loopSwitch.transform = CGAffineTransformMakeScale(switchScale, switchScale)
		blinkSwitch.transform = CGAffineTransformMakeScale(switchScale, switchScale)

		for view in [loopSwitch, loopLabel, blinkSwitch, blinkLabel, brightnessBackground] {
			view.translatesAutoresizingMaskIntoConstraints = false
			mainStack.addSubview(view)
		}
		
		mainStack.sendSubviewToBack(brightnessBackground)
		
		setNeedsUpdateConstraints()
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			scrollView.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(self)
			}
			
			mainStack.snp_makeConstraints { (make) -> Void in
				make.edges.width.equalTo(scrollView)
			}
			
			lightBulb.snp_makeConstraints { (make) -> Void in
				make.height.equalTo(scrollView).multipliedBy(0.4)
			}
			
			loopSwitchPlaceholder.snp_makeConstraints { (make) -> Void in
				make.width.equalTo(blinkSwitchPlaceholder)
			}
			
			loopSwitch.snp_makeConstraints { (make) -> Void in
				make.bottom.equalTo(loopSwitchPlaceholder).multipliedBy(0.85)
				make.centerX.equalTo(loopSwitchPlaceholder)
			}
			
			loopLabel.snp_makeConstraints { (make) -> Void in
				make.centerX.equalTo(loopSwitch)
				make.bottom.equalTo(loopSwitch.snp_top).offset(-30)
			}
			
			blinkSwitch.snp_makeConstraints { (make) -> Void in
				make.centerY.equalTo(loopSwitch)
				make.centerX.equalTo(blinkSwitchPlaceholder)
			}
			
			blinkLabel.snp_makeConstraints { (make) -> Void in
				make.centerX.equalTo(blinkSwitch)
				make.bottom.equalTo(blinkSwitch.snp_top).offset(-30)
			}
			
			brightnessBackground.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(brightnessStack)
			}
			
			colorPicker.snp_makeConstraints { (make) -> Void in
				make.height.equalTo(70)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}

}
