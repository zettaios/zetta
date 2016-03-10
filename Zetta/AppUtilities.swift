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

import ZettaKit

extension ZIKServer {
	var brandColor: UIColor? {
		guard let style = properties["style"] as? [String: AnyObject] else { return nil }
		guard let brandColors = style["colors"] as? [String: AnyObject] else { return nil }
		guard let primary = brandColors["primary"] as? [String: AnyObject] else { return nil }
		guard let decimal = primary["decimal"] as? [String: AnyObject] else { return nil }
		guard let red = decimal["red"] as? CGFloat, green = decimal["green"] as? CGFloat, blue = decimal["blue"] as? CGFloat else { return nil }
		return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
	}
}

extension ZIKDevice {
	var iconURL: NSURL? {
		guard let style = properties["style"] as? [String: AnyObject] else { return nil }
		if let stateImage = style["stateImage"] as? String {
			return NSURL(string: stateImage)
		} else if let typeImage = style["typeImage"] as? String {
			return NSURL(string: typeImage)
		}
		return nil
	}
}