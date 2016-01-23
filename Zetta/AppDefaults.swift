//
//  AppDefaults.swift
//  SessionScanner
//
//  Created by Ben Packard on 4/26/15.
//  Copyright (c) 2015 Spargo. All rights reserved.
//

import Foundation

extension NSUserDefaults {
	
	private struct appKeys {
		static let connectionHistoryKey = "ConnectionHistory"
	}
	
	func registerAppDefaults() {
		let defaults: [String: AnyObject] = [
			appKeys.connectionHistoryKey: [String](),
		]
		registerDefaults(defaults)
	}
	
	var connectionHistory: [NSURL] {
		get {
			let strings = arrayForKey(appKeys.connectionHistoryKey) as? [String] ?? [String]()
			return strings.flatMap{ NSURL(string: $0) }
		}
		set {
			let connectionHistoryLength = 5
			let strings = newValue.map({ $0.absoluteString })
			let trimmed = Array(strings.prefix(connectionHistoryLength))
			setObject(trimmed, forKey: appKeys.connectionHistoryKey)
		}
	}
	
}
