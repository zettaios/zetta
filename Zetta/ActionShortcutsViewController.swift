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
		
		mainView.deviceLabel.text = self.device.name ?? self.device.type ?? "Unnamed Device"
		
		let imageTap = UITapGestureRecognizer(target: self, action: "backgroundTapped:")
		imageTap.numberOfTapsRequired = 1
		mainView.dismissZone.addGestureRecognizer(imageTap)
	
		mainView.tableView.dataSource = self
		
		mainView.tableView.snp_makeConstraints { (make) -> Void in
			make.height.equalTo(device.singleFieldNonHiddenTransitions.count * 60).priorityHigh()
		}
	}
	
	@objc private func backgroundTapped(sender: UIGestureRecognizer) {
		delegate?.didRequestDismiss()
	}
}

extension ActionShortcutsViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return device.singleFieldNonHiddenTransitions.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = actionCellForIndexPath(indexPath)
		cell.backgroundColor = backgroundColor
		cell.tintColor = foregroundColor
		return cell
	}
	
	private func actionCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		let transition = device.singleFieldNonHiddenTransitions[indexPath.row]
//		if transition.fieldNames.isEmpty {
			let cell = NoFieldsActionCell()
			cell.titleLabel.text = transition.name
			cell.goButton.setTitle(transition.name, forState: .Normal)
			cell.delegate = self
			return cell
//		} else if transition.fieldNames.count == 1 {
//			let cell = SingleFieldActionCell(fieldName: transition.fieldNames.first ?? "")
//			cell.goButton.setTitle(transition.name, forState: .Normal)
//			//			cell.delegate = self
//			return cell
//		} else {
//			let cell = MultipleFieldsActionCell(fieldNames: transition.fieldNames)
//			cell.goButton.setTitle(transition.name, forState: .Normal)
//			//			cell.delegate = self
//			return cell
//		}
	}
}

extension ActionShortcutsViewController: ActionCellDelegate {
	func actionCell(cell: UITableViewCell, didSubmitFields fields: [String?]) {
		guard let indexPath = mainView.tableView.indexPathForCell(cell) else { return }
		let transition = device.singleFieldNonHiddenTransitions[indexPath.row]
//		guard transition.fieldNames.count == fields.count else { return } //something went wrong in setup if these don't match
		
		var arguments = [String: String]()
//		for (index, field) in fields.enumerate() {
//			if let field = field {
//				arguments[transition.fieldNames[index]] = field
//			}
//		}
		
		device.transition(transition.name, withArguments: arguments) { [weak self] (error, device) -> Void in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			
			//a new device is returned, representing the latest state
//			if let device = device {
//				dispatch_async(dispatch_get_main_queue(), { () -> Void in
//					self?.device = device
//					self?.updateStateImage()
//					self?.tableView.reloadData()
//				})
//			}
		}
		
		delegate?.didRequestDismiss()
	}
}