//
//  AddConnectionViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/23/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class AddConnectionViewController: UIViewController {

	private var addButton: UIBarButtonItem?
	
	private var mainView: AddConnectionView {
		return self.view as! AddConnectionView
	}
	
	override func loadView() {
		view = AddConnectionView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Add Server"
		addButton = UIBarButtonItem(title: "Add", style: .Done, target: self, action: "addButtonTapped")
		addButton?.enabled = false
		navigationItem.rightBarButtonItem = addButton
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonTapped")
		
		mainView.urlField.addTarget(self, action: "textFieldChanged", forControlEvents: .EditingChanged)
		mainView.urlField.becomeFirstResponder()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		mainView.endEditing(true)
	}
	
	// MARK: - button actions
	
	@objc private func addButtonTapped() {
		guard let urlString = mainView.urlField.text?.nonEmptyTrimmed(), newURL = NSURL(string: urlString) else {
			print("Warning: attempted to add an invalid connection URL.")
			return
		}

		//if the new url is already in the history, bump it to the top. Otherwise, insert it as the top
		let defaults = NSUserDefaults.standardUserDefaults()
		if let existingIndex = defaults.connectionHistory.indexOf(newURL) {
			defaults.connectionHistory.removeAtIndex(existingIndex)
		}
		defaults.connectionHistory.insert(newURL, atIndex: 0)
		
		presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@objc private func cancelButtonTapped() {
		presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: - text field
	
	@objc private func textFieldChanged() {
		if let text = mainView.urlField.text?.nonEmptyTrimmed(), _ = NSURL(string: text) {
			addButton?.enabled = true
		} else {
			addButton?.enabled = false
		}
	}
	
}