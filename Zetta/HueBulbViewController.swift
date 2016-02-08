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
	private var colorStream: ZIKStream?
	
	init?(device: ZIKDevice) {
		super.init(nibName: nil, bundle: nil)
		
		guard device.deviceType == .HueBulb else {
			print("Can't create a Hue Bulb view controller for a device of type \(device.deviceType.rawValue)")
			return nil
		}
		
		self.device = device
		
//		print(device.description)
//		print(device.properties)
//		print(device.state)
		
		//start monitoring the color stream
		if let colorStream = device.stream("colorValue") {
			print("ok")
			self.colorStream = colorStream
			self.colorStream?.signal.subscribeNext { [weak self] (streamEntry) -> Void in
				guard let streamEntry = streamEntry as? ZIKStreamEntry else { return }
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self?.handleStreamEntry(streamEntry)
				})
				print("color change")
				print(streamEntry)
			}
			self.colorStream?.resume()
		} else {
			print("no such stream")
		}
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
		
		if let colorValues = device.properties["colorValue"] as? [Int] {
			updateBulbColor(UIColor(colorValues: colorValues))
		}

//		mainView.loopSwitch.enabled = false
//		mainView.blinkSwitch.enabled = false
		mainView.brightnessSlider.value = 0.5
//		mainView.brightnessSlider.enabled = false
		mainView.colorPicker.colors = [
			UIColor(red:0.808, green:0.867, blue:0.224, alpha:1),
			UIColor(red:0.549, green:0.769, blue:0.290, alpha:1),
			UIColor(red:0.298, green:0.686, blue:0.314, alpha:1),
			UIColor(red:0.000, green:0.592, blue:0.533, alpha:1),
			UIColor(red:0.008, green:0.729, blue:0.824, alpha:1),
			UIColor(red:0.020, green:0.576, blue:0.827, alpha:1),
			UIColor(red:0.133, green:0.592, blue:0.957, alpha:1)
		]
		mainView.colorPicker.delegate = self
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.colorStream?.stop()
	}
	
	private func updateBulbColor(color: UIColor?) {
		mainView.filledLightBulb.tintColor = color ?? .clearColor()
	}
	
	private func handleStreamEntry(streamEntry: ZIKStreamEntry) {
		print("new: \(streamEntry)")
		if let colorValues = device.properties["colorValue"] as? [Int] {
			updateBulbColor(UIColor(colorValues: colorValues))
		} else {
			updateBulbColor(nil)
		}
	}
	
}

extension HueBulbViewController: ColorPickerDelegate {
	func colorPicker(colorPicker: ColorPicker, didPickColorAtIndex index: Int) {
 		if index < colorPicker.colors.count {
			print(colorPicker.colors[index])
		}
	}
}