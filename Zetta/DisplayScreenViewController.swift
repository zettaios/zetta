//
//  DisplayScreenViewController.swift
//  Zetta
//
//  Created by Ben Packard on 2/4/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit

protocol DisplayScreenDelegate: class {
	func displayScreenController(controller: DisplayScreenViewController, didTransitionDevice device: ZIKDevice)
}

class DisplayScreenViewController: UIViewController {
	
	weak var delegate: DisplayScreenDelegate?
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
		mainView.newMessageField.delegate = self
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.messageStream?.stop()
	}
	
	// MARK: - stream handling
	
	private func handleStreamEntry(streamEntry: ZIKStreamEntry) {
		if let message = streamEntry.data as? String {
			updateMessage(message, animated: true)
		}
	}
	
	private func updateMessage(message: String?, animated: Bool) {
		if let message = message where !message.isEmpty {
			mainView.messageLabel.text = "Display: \(message)"
		} else {
			mainView.messageLabel.text = "Display: None"
		}
		
		//handle size changes gracefully (also adds some polish to a single-line text change)
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
	
	// MARK: - changing the message
	
	private func changeMessage(message: String) {
		self.mainView.newMessageField.text = nil
		device.transition("change", withArguments: ["message": message], andCompletion: { [weak self] (error, device) -> Void in
			if let error = error {
				print(error)
				return
			}
			
			if let unwrappedSelf = self {
				unwrappedSelf.delegate?.displayScreenController(unwrappedSelf, didTransitionDevice: device)
			}
		})
	}
	
}

extension DisplayScreenViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		guard let text = textField.text else { return false }
		changeMessage(text)
		return false
	}
	
}
