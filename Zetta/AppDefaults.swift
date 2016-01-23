//
//  AppDefaults.swift
//  SessionScanner
//
//  Created by Ben Packard on 4/26/15.
//  Copyright (c) 2015 Spargo. All rights reserved.
//

import Foundation

extension NSUserDefaults {
	
	struct appKeys {
		static let connectionHistoryKey = "ConnectionHistory"
	}
	
	func registerAppDefaults() {
		let defaults: [String: AnyObject] = [
			appKeys.connectionHistoryKey: [String](),
		]
		registerDefaults(defaults)
	}
	
	var connectionHistory: [String] {
		get {
			return arrayForKey(appKeys.connectionHistoryKey) as? [String] ?? [String]()
		}
		set {
			setObject(newValue, forKey: appKeys.connectionHistoryKey)
		}
	}
	
}
