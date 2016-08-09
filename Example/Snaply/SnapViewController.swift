//
//  SnapViewController.swift
//  Snap
//
//  Created by Shaps Mohsenin on 30/07/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Snaply

final class SnapViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  @IBOutlet private var leftAlignedCollectionView: UICollectionView!
  @IBOutlet private var centerAlignedCollectionView: UICollectionView!
  @IBOutlet private var rightAlignedCollectionView: UICollectionView!
  
  private var left: Snap!
  private var center: Snap!
  private var right: Snap!
  
  private var leftLayout: UICollectionViewFlowLayout! {
    return leftAlignedCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
  }
  
  private var centerLayout: UICollectionViewFlowLayout! {
    return centerAlignedCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
  }
  
  private var rightLayout: UICollectionViewFlowLayout! {
    return rightAlignedCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leftAlignedCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    centerAlignedCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    rightAlignedCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    
    let size = leftAlignedCollectionView.bounds.size
    
    leftLayout.itemSize = CGSize(width: size.height * 0.8, height: size.height)
    centerLayout.itemSize = CGSize(width: size.height * 1.5, height: size.height)
    rightLayout.itemSize = CGSize(width: size.height * 0.8, height: size.height)
    
    left = Snap(scrollView: leftAlignedCollectionView, edge: .min, direction: .horizontal, delegate: self)
    center = Snap(scrollView: centerAlignedCollectionView, edge: .mid, direction: .horizontal, delegate: self)
    right = Snap(scrollView: rightAlignedCollectionView, edge: .max, direction: .horizontal, delegate: self)
    
    left.setSnapLocations(locations(snap: left, layout: leftLayout), realignImmediately: true)
    center.setSnapLocations(locations(snap: center, layout: centerLayout), realignImmediately: true)
    right.setSnapLocations(locations(snap: right, layout: rightLayout), realignImmediately: true)
  }
  
  private func locations(snap: Snap, layout: UICollectionViewFlowLayout) -> [CGFloat] {
    var locations = [CGFloat]()
    var sizes = [CGFloat]()
    
    for _ in 0..<20 {
      let itemSize = layout.itemSize.width
      sizes.append(itemSize)
      
      switch snap.snappingEdge() {
      case .min:
        let offset = layout.headerReferenceSize.width + layout.sectionInset.left
        let size = sizes.reduce(offset, combine: { $0 + $1 + layout.minimumInteritemSpacing })
        locations.append(size - offset)
      case .mid:
        let offset = (layout.headerReferenceSize.width + layout.sectionInset.left) / 2
        let size = sizes.reduce(offset, combine: { $0 + $1 + layout.minimumInteritemSpacing })
        locations.append(size + offset - itemSize / 2 - layout.minimumInteritemSpacing)
      case .max:
        let offset = layout.footerReferenceSize.width + layout.sectionInset.right
        let size = sizes.reduce(offset, combine: { $0 + $1 + layout.minimumInteritemSpacing })
        locations.append(size - offset + layout.minimumInteritemSpacing)
      }
    }
    
    return locations
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 20
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
  }
  
}
