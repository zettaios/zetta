//
//  Device+DeviceType.swift
//  Zetta
//
//  Created by Ben Packard on 2/3/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import Foundation

enum DeviceType: String {
	case Display = "display", Unknown
}

import ZettaKit

extension ZIKDevice {
	
	var deviceType: DeviceType {
		return DeviceType(rawValue: type) ?? .Unknown
	}
		
}