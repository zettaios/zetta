//
//  HueBulbViewController.swift
//  Zetta
//
//  Created by Ben Packard on 2/5/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit

class HueBulbViewController: UIViewController {

	private var device: ZIKDevice!
	
	init?(device: ZIKDevice) {
		super.init(nibName: nil, bundle: nil)
		
		guard device.deviceType == .HueBulb else {
			print("Can't create a Hue Bulb view controller for a device of type \(device.deviceType.rawValue)")
			return nil
		}
		
		self.device = device
		
		print(device.description)
		print(device.properties)
		
//		//start monitoring the message stream
//		if let messageStream = device.stream("message") {
//			self.messageStream = messageStream
//			self.messageStream?.signal.subscribeNext { [weak self] (streamEntry) -> Void in
//				guard let streamEntry = streamEntry as? ZIKStreamEntry else { return }
//				dispatch_async(dispatch_get_main_queue(), { () -> Void in
//					self?.handleStreamEntry(streamEntry)
//				})
//			}
//			self.messageStream?.resume()
//		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	private var mainView: HueBulbView {
		return self.view as! HueBulbView
	}
	
	override func loadView() {
		view = HueBulbView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		title = device.name ?? "Unnamed Device"
	}
	
}
