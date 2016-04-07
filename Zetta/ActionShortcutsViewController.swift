//
//  ActionShortcutsViewController.swift
//  Zetta
//
//  Created by Ben Packard on 4/6/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import ZettaKit

protocol ActionShortcutsDelegate: class {
	func didRequestDismiss()
}

class ActionShortcutsViewController: UIViewController {
	weak var delegate: ActionShortcutsDelegate?
	private let device: ZIKDevice
	
	var foregroundColor: UIColor = UIColor.blackColor() {
		didSet {
			mainView.tableView.reloadData()
		}
	}
	
	var backgroundColor: UIColor = UIColor.whiteColor() {
		didSet {
			mainView.tableView.backgroundColor = backgroundColor
			mainView.tableView.reloadData()
		}
	}
	
	init(device: ZIKDevice) {
		self.device = device
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	private var mainView: ActionShortcutsView {
		return self.view as! ActionShortcutsView
	}
	
	override func loadView() {
		view = ActionShortcutsView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
		
		mainView.deviceLabel.text = self.device.name ?? self.device.type ?? "Unnamed Device"
		
		let imageTap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
		imageTap.numberOfTapsRequired = 1
		mainView.dismissZone.addGestureRecognizer(imageTap)
	
		mainView.tableView.dataSource = self
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		mainView.endEditing(true)
	}
	
	@objc private func backgroundTapped(sender: UIGestureRecognizer) {
		delegate?.didRequestDismiss()
	}
	
	// MARK: - keyboard management
	
	@objc private func keyboardWillShow(notification: NSNotification) {
		if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size.height {
			mainView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
			mainView.tableView.scrollIndicatorInsets = mainView.tableView.contentInset
		}
	}
	
	@objc private func keyboardWillHide(notification: NSNotification) {
		mainView.tableView.contentInset = UIEdgeInsetsZero
		mainView.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
	}
}

extension ActionShortcutsViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return device.nonHiddenTransitions.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = actionCellForIndexPath(indexPath)
		cell.backgroundColor = backgroundColor
		cell.tintColor = foregroundColor
		return cell
	}
	
	private func actionCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		let transition = device.nonHiddenTransitions[indexPath.row]
		if transition.fieldNames.isEmpty {
			let cell = NoFieldsActionCell()
			cell.titleLabel.text = transition.name
			cell.goButton.setTitle(transition.name, forState: .Normal)
			cell.delegate = self
			return cell
		} else if transition.fieldNames.count == 1 {
			let cell = SingleFieldActionCell(fieldName: transition.fieldNames.first ?? "")
			cell.goButton.setTitle(transition.name, forState: .Normal)
			cell.delegate = self
			return cell
		} else {
			let cell = MultipleFieldsActionCell(fieldNames: transition.fieldNames)
			cell.goButton.setTitle(transition.name, forState: .Normal)
			cell.delegate = self
			return cell
		}
	}
}

extension ActionShortcutsViewController: ActionCellDelegate {
	func actionCell(cell: UITableViewCell, didSubmitFields fields: [String?]) {
		guard let indexPath = mainView.tableView.indexPathForCell(cell) else { return }
		let transition = device.nonHiddenTransitions[indexPath.row]
		guard transition.fieldNames.count == fields.count else { return } //something went wrong in setup if these don't match
		
		var arguments = [String: String]()
		for (index, field) in fields.enumerate() {
			if let field = field {
				arguments[transition.fieldNames[index]] = field
			}
		}
		
		device.transition(transition.name, withArguments: arguments) { (error, device) -> Void in
			if let error = error {
				print(error.localizedDescription)
			}
		}
		
		delegate?.didRequestDismiss()
	}
}