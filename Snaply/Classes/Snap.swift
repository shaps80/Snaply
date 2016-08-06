//
//  Snap.swift
//  Pods
//
//  Created by Shaps Mohsenin on 13/07/2016.
//
//

import UIKit

/*
 Snap can be used to provide 'paging' behaviour to a scrollView with arbitrarily sized content.
 This class also provides advanced snapping behaviour such as edge alignment.
 Snap is designed to completely plug-n-play.
 */
public final class Snap: NSObject, UIScrollViewDelegate {
  
  // MARK: Variables
  
  /// The scrollView this class should apply Snap to
  private weak var scrollView: UIScrollView!
  /// The original delegate to forward all delegate methods to so that existing behaviour is still handled
  private weak var originalDelegate: UIScrollViewDelegate?
  /// The supported direction
  private var snapDirection: SnapDirection
  /// The edge to snap to
  public private(set) var snapEdge: SnapEdge
  /// The current snap locations
  private var locations = [CGFloat]()
  
  // MARK: Lifecycle
  
  /**
   Initializes Snap with a scrollView
   
   - parameter scrollView: The scrollView to apply snapping to
   - parameter edge:       The scrollView edge to snap to
   - parameter direction:  The scrollView direction to apply snapping
   - parameter delegate:   The original scrollView delegate. If nil, scrollView.delegate will be used
   
   - returns: A new instance of Snap
   */
  public init(scrollView: UIScrollView, edge: SnapEdge = .Min, direction: SnapDirection = .Automatic, delegate: UIScrollViewDelegate? = nil) {
    self.scrollView = scrollView
    self.originalDelegate = delegate ?? scrollView.delegate
    self.snapDirection = direction
    self.snapEdge = edge
    
    super.init()
    scrollView.delegate = self
  }
  
  // MARK: Public functions
  
  /**
   Scrolls to the nearest snap point, relative to the specified offset
   
   - parameter offset: The content offset
   */
  public func scrollToNearestSnapLocationForTargetContentOffset(offset: CGPoint) {
    let contentOffset = contentOffsetForTargetContentOffset(offset)
    scrollView?.setContentOffset(contentOffset, animated: true)
  }
  
  /**
   Called when dragging stops inside the scrollView
   
   - parameter scrollView:          The scrollView that was being dragged
   - parameter velocity:            The velocity as dragging stopped
   - parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop
   */
  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard locations.count > 0 else { return }
    
    let direction = supportedDirection()
    let offset = contentOffsetForTargetContentOffset(targetContentOffset.memory)
    let dragVelocity = (direction == .Horizontal ? abs(velocity.x) : abs(velocity.y))
    
    guard dragVelocity > 0 else {
      scrollView.setContentOffset(offset, animated: true)
      return
    }
    
    targetContentOffset.memory = offset
    scrollView.setContentOffset(offset, animated: true) // fixes a flicker bug
    originalDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }
  
  /**
   Returns the content offset for a target offset, taking into account the snap locations
   
   - parameter offset: The target offset (generally provided by the scrollView)
   
   - returns: The snap offset
   */
  public func contentOffsetForTargetContentOffset(offset: CGPoint) -> CGPoint {
    let direction = supportedDirection()
    var next: CGFloat = 0
    var prev: CGFloat = 0
    var offsetValue = direction == .Horizontal ? offset.x : offset.y
    let bounds = direction == .Horizontal ? scrollView.bounds.width : scrollView.bounds.height
    
    guard offsetValue > 0 else {
      return CGPoint.zero
    }
    
    switch snapEdge {
    case .Min:
      break
    case .Mid:
      offsetValue += bounds / 2
    case .Max:
      offsetValue += bounds
    }
    
    if let location = locations.last where offsetValue > locations.last {
      return direction == .Horizontal ? CGPoint(x: location, y: 0) : CGPoint(x: 0, y: location)
    }
    
    for i in 0..<locations.count {
      next = locations[i]
      
      if next > offsetValue {
        let index = max(0, min(locations.count - 1, i - 1))
        prev = locations[index]
        break
      }
    }
    
    next = min(next, maximumValue())
    
    let spanValue = fabs(next - prev)
    let midValue = next - (spanValue / 2)
    
    if midValue <= 0 {
      return CGPoint.zero
    }
    
    var location: CGFloat = next
    
    if offsetValue < midValue {
      location = prev
    }
    
    switch snapEdge {
    case .Min:
      break
    case .Mid:
      location -= bounds / 2
    case .Max:
      location -= bounds
    }
    
    location = max(location, 0) // clamp our values
    return direction == .Horizontal ? CGPoint(x: location, y: 0) : CGPoint(x: 0, y: location)
  }
  
  /**
   Returns the supported direction. When direction == .Automatic, and the scrollView is a collectionView using a flow layout, the direction property will be used to determine direction. If the scrollView is a tableView, then this will always return Vertical. In all other cases the direction will be determined by comparing the scrollView's contentSize and looking for the larger value. When no direction can be determined, this defaults to Vertical. 
   
   - returns: The supported snap direction
   */
  public func supportedDirection() -> SnapDirection {
    if let _ = scrollView as? UITableView {
      return .Vertical
    }
    
    guard snapDirection == .Automatic else {
      return snapDirection
    }
    
    if let collectionView = scrollView as? UICollectionView,
      layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      return layout.scrollDirection == .Vertical ? .Vertical : .Horizontal
    }
    
    return scrollView.contentSize.width > scrollView.contentSize.height ? .Horizontal : .Vertical
  }

  
  // MARK: Public Setters
  
  /**
   Updates the snap locations
   
   - parameter locations:          The new locations to apply
   - parameter realignImmediately: If true, the scrollView will automatically re-align to the nearest location based on its current offset.
   */
  public func setSnapLocations(locations: [CGFloat], realignImmediately: Bool) {
    let offset = scrollView.contentOffset
    
    // Remove duplicates and sort the resulting values
    var locs = [CGFloat]()
    locs.append(0)
    locs.appendContentsOf(locations)
    
    self.locations = Set(locs).sort()
    
    guard realignImmediately else { return }
    scrollToNearestSnapLocationForTargetContentOffset(offset)
  }
  
  /**
   Updates the snap edge to use when snapping to a location
   
   - parameter edge:               The edge to snap to
   - parameter realignImmediately: If true, the scrollView will automatically re-align to the nearest location based on its current offset.
   */
  public func setSnapEdge(edge: SnapEdge, realignImmediately: Bool) {
    self.snapEdge = edge
    guard realignImmediately else { return }
    scrollToNearestSnapLocationForTargetContentOffset(scrollView.contentOffset)
  }
  
  /**
   Updates the snap direction to apply snapping to
   
   - parameter direction:          The direction to apply snapping behaviour
   - parameter realignImmediately: If true, the scrollView will automatically re-align to the nearest location based on its current offset.
   */
  public func setSnapDirection(direction: SnapDirection, realignImmediately: Bool) {
    self.snapDirection = direction
    guard realignImmediately else { return }
    scrollToNearestSnapLocationForTargetContentOffset(scrollView.contentOffset)
  }
  
  // MARK: Delegate forwarding
  
  public override func respondsToSelector(aSelector: Selector) -> Bool {
    if super.respondsToSelector(aSelector) {
      return true
    }
    
    if originalDelegate?.respondsToSelector(aSelector) ?? false {
      return true
    }
    
    return false
  }
  
  public override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
    if super.respondsToSelector(aSelector) {
      return self
    }
    
    return originalDelegate
  }
  
  // MARK: Helpers
  
  private func maximumValue() -> CGFloat {
    switch snapEdge {
    case .Min:
      return supportedDirection() == .Horizontal
        ? scrollView.contentSize.width - scrollView.bounds.width
        : scrollView.contentSize.height - scrollView.bounds.height
    case .Mid:
      return supportedDirection() == .Horizontal
        ? scrollView.contentSize.width - scrollView.bounds.width / 2
        : scrollView.contentSize.height - scrollView.bounds.height / 2
    case .Max:
      return supportedDirection() == .Horizontal
        ? scrollView.contentSize.width
        : scrollView.contentSize.height
    }
  }
  
  // MARK: Debugging
  
  public override var description: String {
    return "\(super.description), Locations:\n\(locations)"
  }
  
}
