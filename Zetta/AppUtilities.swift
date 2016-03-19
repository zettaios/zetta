//
//  AppUtilities.swift
//  Zetta
//
//  Created by Ben Packard on 1/16/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
	dispatch_after(
		dispatch_time(
			DISPATCH_TIME_NOW,
			Int64(delay * Double(NSEC_PER_SEC))
		),
		dispatch_get_main_queue(), closure)
}

extension String {	
	func nonEmptyTrimmed() -> String? {
		let trimmed = self.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
		return !trimmed.isEmpty ? trimmed : nil
	}
}

extension UIColor
{
	var isLight: Bool {
		let components = CGColorGetComponents(self.CGColor)
		let red = components[0] * 299
		let green = components[1] * 587
		let blue = components[2] * 114
		let brightness = [red, green, blue].reduce(0, combine: +)
		return brightness/1000 >= 0.5
	}
	
	private class func colorFromDecimalJSON(json: JSON) -> UIColor? {
		guard let red = json["red"].float, green = json["green"].float, blue = json["blue"].float else { return nil }
		return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
	}
}

import ZettaKit

extension ZIKServer {
	var foregroundColor: UIColor? {
		let decimal = JSON(properties)["style"]["foregroundColor"]["decimal"]
		return UIColor.colorFromDecimalJSON(decimal)
	}
	
	var backgroundColor: UIColor? {
		let decimal = JSON(properties)["style"]["backgroundColor"]["decimal"]
		return UIColor.colorFromDecimalJSON(decimal)
	}
}

import SwiftyJSON

extension ZIKDevice {
	var iconURL: NSURL? {
		if let stateImage = JSON(properties)["style"]["stateImage"].URL {
			return stateImage
		} else if let typeImage = JSON(properties)["style"]["typeImage"].URL {
			return typeImage
		}
		return nil
	}
}