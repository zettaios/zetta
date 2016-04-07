//
//  AppUtilities.swift
//  Zetta
//
//  Created by Ben Packard on 1/16/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
	dispatch_after(
		dispatch_time(
			DISPATCH_TIME_NOW,
			Int64(delay * Double(NSEC_PER_SEC))
		),
		dispatch_get_main_queue(), closure)
}

extension String {	
	func nonEmptyTrimmed() -> String? {
		let trimmed = self.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
		return !trimmed.isEmpty ? trimmed : nil
	}
}

extension UIColor
{
	var isLight: Bool {
		let components = CGColorGetComponents(self.CGColor)
		let red = components[0] * 299
		let green = components[1] * 587
		let blue = components[2] * 114
		let brightness = [red, green, blue].reduce(0, combine: +)
		return brightness/1000 >= 0.5
	}
	
	private class func colorFromDecimalJSON(json: JSON) -> UIColor? {
		guard let red = json["red"].float, green = json["green"].float, blue = json["blue"].float else { return nil }
		return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
	}
}

class NavigationTitleView: UIView {
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFontOfSize(16)
		label.setContentHuggingPriority(1000, forAxis: .Vertical)
		return label
	}()
	
	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFontOfSize(12)
		label.setContentHuggingPriority(1000, forAxis: .Vertical)
		return label
	}()
	
	init(title: String?, subtitle: String?) {
		super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 44))
		
		titleLabel.text = title
		titleLabel.hidden = title?.isEmpty != false
		
		subtitleLabel.text = subtitle
		subtitleLabel.hidden = subtitle?.isEmpty != false
		
		let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
		stack.axis = .Vertical
		stack.alignment = .Center
		subtitleLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
		
		stack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stack)
		stack.snp_makeConstraints { (make) -> Void in
			make.center.equalTo(self)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	var foregroundColor: UIColor = UIColor.blackColor() {
		didSet {
			titleLabel.textColor = foregroundColor
			subtitleLabel.textColor = foregroundColor
		}
	}
}

import ZettaKit

extension ZIKServer {
	var foregroundColor: UIColor? {
		let decimal = JSON(properties)["style"]["properties"]["foregroundColor"]["decimal"]
		return UIColor.colorFromDecimalJSON(decimal)
	}
	
	var backgroundColor: UIColor? {
		let decimal = JSON(properties)["style"]["properties"]["backgroundColor"]["decimal"]
		return UIColor.colorFromDecimalJSON(decimal)
	}
}

import SwiftyJSON

extension ZIKDevice {
	var iconURL: NSURL? {
		if let stateImage = JSON(properties)["style"]["properties"]["stateImage"]["url"].URL {
			return stateImage
		} else if let typeImage = JSON(properties)["style"]["properties"]["typeImage"]["url"].URL {
			return typeImage
		}
		return nil
	}
	
	var iconTintMode: UIImageRenderingMode {
		return JSON(properties)["style"]["properties"]["stateImage"]["tintMode"].string == "original" ? .AlwaysOriginal : .AlwaysTemplate
	}
	
	var foregroundColor: UIColor? {
		let decimal = JSON(properties)["style"]["properties"]["foregroundColor"]["decimal"]
		return UIColor.colorFromDecimalJSON(decimal)
	}
	
	var backgroundColor: UIColor? {
		let decimal = JSON(properties)["style"]["properties"]["backgroundColor"]["decimal"]
		return UIColor.colorFromDecimalJSON(decimal)
	}
}

extension ZIKDevice {
	var nonHiddenTransitions: [ZIKTransition] {
		guard let transitions = transitions as? [ZIKTransition] else { return [ZIKTransition]() }
		return transitions.filter({ displayStyleForTranstion($0) != .None })
	}
	
	private func displayStyleForTranstion(transition: ZIKTransition) -> DisplayStyle {
		let defaultStyle: DisplayStyle = .Inline
		if let displayString = JSON(properties)["style"]["actions"][transition.name]["display"].string {
			return DisplayStyle(rawValue: displayString) ?? defaultStyle
		}
		return defaultStyle
	}
}

enum DisplayStyle: String {
	case None = "none", Billboard = "billboard", Inline = "inline"
}

extension ZIKTransition {
	var fieldNames: [String] {
		var fieldNames = [String]()
		guard let fields = fields as? [[String: AnyObject]] else { return fieldNames }
		for field in fields {
			if let type = field["type"] as? String where type != "hidden", let name = field["name"] as? String {
				fieldNames.append(name)
			}
		}
		return fieldNames
	}
}
