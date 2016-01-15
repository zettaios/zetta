//
//  NoServerViewController.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class ConnectionViewController: UIViewController {

	private var mainView: ConnectionView {
		return self.view as! ConnectionView
	}
	
	override func loadView() {
		view = ConnectionView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Zetta"
		
		mainView.spinner.startAnimating()
		mainView.titleLabel.text = "Title"
		mainView.subtitleLabel.text = "Subtitle"
		mainView.settingsButton.setTitle("Open Settings", forState: .Normal)
		mainView.settingsButton.addTarget(self, action: "openSettingsButtonTapped", forControlEvents: .TouchUpInside)
		mainView.settingsButton.hidden = false
		
		
		
//		noServerLabel.text = "You are not connected to a server.\n\nServers can be managed in the Settings app."

	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
//		openSettingsButtonTapped()
	}
	
	// MARK: - button actions
	
	@objc private func openSettingsButtonTapped() {
		// deep link into the specific app's settings screen
		if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
}
