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
	
	class func appDarkGrayColor() -> UIColor {
		return UIColor(white: 0.290, alpha: 1)
	}
	
	class func appMediumGrayColor() -> UIColor {
		return UIColor(white: 0.612, alpha: 1)
	}
	
	class func tableViewSeparatorColor() -> UIColor {
		return UIColor(red:0.863,  green:0.863,  blue:0.878, alpha:1)
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