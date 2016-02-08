//
//  ColorPicker.swift
//  Zetta
//
//  Created by Ben Packard on 2/7/16.
//  Copyright © 2016 Zetta. All rights reserved.
//

import UIKit


protocol ColorPickerDelegate: class {
	func colorPicker(colorPicker: ColorPicker, didPickColorAtIndex index: Int)
}

class ColorPicker: UIView {

	weak var delegate: ColorPickerDelegate?
	var colors = [UIColor]()
	
	var selectedIndex: Int? {
		didSet {
			for cell in collectionView.visibleCells() {
				if let cell = cell as? ColorPickerCell {
					cell.showCheckmark = collectionView.indexPathForCell(cell)?.row == selectedIndex
				}
			}
		}
	}
	
	private let cellIdentifier = "Cell"
	private var constraintsAdded = false
	
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .Horizontal
		layout.minimumLineSpacing = 0
		let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
		collectionView.backgroundColor = UIColor(white: 0.975, alpha: 1)
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.registerClass(ColorPickerCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(collectionView)
		
		setNeedsUpdateConstraints()
	}
	
	override func updateConstraints() {
		if !constraintsAdded {
			collectionView.snp_makeConstraints { (make) -> Void in
				make.edges.equalTo(self)
			}
			
			constraintsAdded = true;
		}
		
		super.updateConstraints()
	}

}

extension ColorPicker: UICollectionViewDataSource, UICollectionViewDelegate {
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return colors.count
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: 60, height: collectionView.bounds.size.height)
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as? ColorPickerCell else { return UICollectionViewCell() }
		cell.contentView.backgroundColor = colors[indexPath.row]
		cell.showCheckmark = indexPath.row == selectedIndex
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		selectedIndex = indexPath.row
		if let selectedIndex = selectedIndex {
			delegate?.colorPicker(self, didPickColorAtIndex: selectedIndex)
		}
	}
	
}
