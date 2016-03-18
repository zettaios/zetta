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

	
	
//	enum DisplayStyle: String {
//		case None = "none", Billboard = "billboard", Inline = "inline"
//	}
//
//	func displayStyleForTranstion(transition: ZIKTransition) -> DisplayStyle {
//		let defaultStyle: DisplayStyle = .Inline
//		guard let actionStyles = JSON(properties)["style"]["actions"].array else { return defaultStyle }
//		let matchingActionStyles = actionStyles.filter({ $0["action"].string == transition.name })
//		if matchingActionStyles.count > 1 { print("Warning: multiple styles specidifed for action'\(transition.name)'. The first style will be used.") }
//		guard let displayString = matchingActionStyles.first?["display"].string else { return defaultStyle }
//		return DisplayStyle(rawValue: displayString) ?? defaultStyle
//	}

//	struct Billboard {
//		let name, title, subtitle: String
//
//		init(name: String, title: String, subtitle: String) {
//			self.name = name
//			self.title = title
//			self.subtitle = subtitle
//		}
//	}
//	
//	var billboards: [[String: AnyObject]] {
//		// TO DO: - check that there is a matching stream and attach it
//		//find properties in the style object with display type `billboard`. Make sure there is a corresponding stream of the same name. Build a `Billboard` object for the property.
//		guard let propertyStyles = JSON(properties)["style"]["properties"].array else { return [[String: AnyObject]]() }
//		let billboardObjects = propertyStyles.filter({ $0["display"].string == "billboard" })
//		for object in billboardObjects  {
//			guard let name = object["name"].string, title = "" else { continue }
//			
//		}
//		
//		
//		return [[String: AnyObject]]()
//	}

}