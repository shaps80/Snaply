//
//  SnapTypes.swift
//  Pods
//
//  Created by Shaps Mohsenin on 23/07/2016.
//
//

import UIKit

/**
 Defines the scrollView's snap direction
 
 - Automatic:  If the scrollView is a collectionView and is using a flow layout, the direction property will be used to determine direction. If the scrollView is a tableView, then this will always return Vertical. In all other cases the direction will be determined by comparing the scrollView's contentSize and looking for the larger value. When no direction can be determined, this defaults to Vertical
 - Vertical:   Snapping is only applied in the vertical direction
 - Horizontal: Snapping is only applied in the horizontal direction
 */
public enum SnapDirection {
  
  /// If the scrollView is a collectionView and is using a flow layout, the direction property will be used to determine direction. If the scrollView is a tableView, then this will always return Vertical. In all other cases the direction will be determined by comparing the scrollView's contentSize and looking for the larger value. When no direction can be determined, this defaults to Vertical
  case automatic
  
  /// Snapping is only applied in the vertical direction
  case vertical
  
  /// Snapping is only applied in the horizontal direction
  case horizontal
  
}


/**
 Defines the edge that will be used for snapping
 
 - Min: The scrollView will snap to the min edge (left for horizontal, top for vertical)
 - Mid: The scrollView will snap to the center/middle of the scrollView
 - Max: The scrollView will snap to the max edge (right for horizontal, bottom for vertical)
 */
public enum SnapEdge {
  
  /// The scrollView will snap to the min edge (left for horizontal, top for vertical)
  case min
  
  /// The scrollView will snap to the center/middle of the scrollView
  case mid
  
  /// The scrollView will snap to the max edge (right for horizontal, bottom for vertical)
  case max
  
}

