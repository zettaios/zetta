
//  AppDelegate.swift
//  Zetta
//
//  Created by Ben Packard on 1/15/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit
import SnapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		NSUserDefaults.standardUserDefaults().registerAppDefaults()
		
		var configureError: NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(configureError)")
		GAI.sharedInstance().trackUncaughtExceptions = true
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		let controller = DeviceListViewController()
		let nav = UINavigationController(rootViewController: controller)
		window?.rootViewController = nav
		window?.makeKeyAndVisible()
		
		customizeUI()
		
		return true
	}
	
	private func customizeUI() {
		window?.tintColor = UIColor.appTintColor()
		UINavigationBar.appearance().translucent = false
	}

}

