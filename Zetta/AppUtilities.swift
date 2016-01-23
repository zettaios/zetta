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