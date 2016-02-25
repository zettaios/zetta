//
//  AppStyles.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import Foundation

import UIKit

extension UIFont {
	
	
}

extension UIColor {
	
	class func appTintColor() -> UIColor {
		return UIColor(red:0.980,  green:0.271,  blue:0.125, alpha:1)
	}
	
	class func appDarkGrayColor() -> UIColor {
		return UIColor(white: 0.290, alpha: 1)
	}
	
	class func appMediumGrayColor() -> UIColor {
		return UIColor(white: 0.612, alpha: 1)
	}
	
	class func tableViewSeparatorColor() -> UIColor {
		return UIColor(red:0.784,  green:0.780,  blue:0.800, alpha:1)
	}
	
	convenience init?(colorValues: [Int]) {
		guard colorValues.count == 3 else { return nil }
		let red = CGFloat(colorValues[0])
		let green = CGFloat(colorValues[1])
		let blue = CGFloat(colorValues[2])
		self.init(red: red, green: green, blue: blue, alpha: 1)
	}
	
}

extension UIView {
	
	class func hairline() -> UIView {
		let line = UIView()
		line.backgroundColor = UIColor.tableViewSeparatorColor()
		return line
	}
	
}

extension UILabel {

	class func devicePropertyLabel(text text: String?) -> UILabel {
		let label = UILabel()
		label.text = text
		label.font = UIFont.systemFontOfSize(13)
		label.textColor = UIColor.lightGrayColor()
		label.textAlignment = .Center
		return label
	}

}

extension UIButton {
	
	class func deviceActionButton(title title: String?) -> UIButton {
		let button = UIButton(type: .System)
		button.setTitle(title, forState: .Normal)
		button.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
		button.backgroundColor = UIColor.appTintColor()
		button.tintColor = UIColor.whiteColor()
		button.layer.cornerRadius = 3
		button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		return button
	}
	
}