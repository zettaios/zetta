//
//  DisplayScreenViewController.swift
//  Zetta
//
//  Created by Ben Packard on 2/4/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit

class DisplayScreenViewController: UIViewController {
	
	private var device: ZIKDevice!
	private var messageStream: ZIKStream?

	init?(device: ZIKDevice) {
		super.init(nibName: nil, bundle: nil)

		guard device.deviceType == .Display else {
			print("Can't create a Display Screen view controller for a device of type \(device.deviceType.rawValue)")
			return nil
		}
		
		self.device = device
		
		//start monitoring the message stream
		if let messageStream = device.stream("message") {
			self.messageStream = messageStream
			self.messageStream?.signal.subscribeNext { [weak self] (streamEntry) -> Void in
				guard let streamEntry = streamEntry as? ZIKStreamEntry else { return }
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self?.handleStreamEntry(streamEntry)
				})
			}
			self.messageStream?.resume()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	private var mainView: DisplayScreenView {
		return self.view as! DisplayScreenView
	}
	
	override func loadView() {
		view = DisplayScreenView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		title = device.name ?? "Unnamed Device"
		updateMessage(device.properties["message"] as? String, animated: false)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.messageStream?.stop()
	}
	
	private func updateMessage(message: String?, animated: Bool) {
		if let message = message where !message.isEmpty {
			mainView.messageLabel.text = "Display: \(message)"
		} else {
			mainView.messageLabel.text = "Display: None"
		}
		
		//handle size changes gracefully (also adds some polish to a dingleline text change)
		if animated {
			mainView.messageLabel.alpha = 0
			UIView.animateWithDuration(0.25, animations: { [weak self] () -> Void in
				self?.mainView.layoutIfNeeded()
			}, completion: { [weak self] (_) -> Void in
				UIView.animateWithDuration(0.25, animations: { () -> Void in
					self?.mainView.messageLabel.alpha = 1
				})
			})
		}
	}
	
	// MARK: - stream handling
	
	private func handleStreamEntry(streamEntry: ZIKStreamEntry) {
		if let message = streamEntry.data as? String {
			updateMessage(message, animated: true)
		}
	}
	
}
