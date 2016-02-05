//
//  HueBulbView.swift
//  Zetta
//
//  Created by Ben Packard on 2/5/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit

class HueBulbView: UIView {

	private var constraintsAdded = false
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.alwaysBounceVertical = false
		return scrollView
	}()
	
	private let contentView = UIView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		backgroundColor = UIColor.groupTableViewBackgroundColor()
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(scrollView)
		
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)
		
		for view in [UIView]() {
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		setNeedsUpdateConstraints()
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			scrollView.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(self)
			}
			
			contentView.snp_makeConstraints { (make) -> Void in
				make.edges.width.equalTo(scrollView)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}

}
