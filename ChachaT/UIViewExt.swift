//
//  UIViewExt.swift
//  MagicMove
//
//  Created by Patrick Reynolds on 1/24/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit

// MARK: - UIView GestureRecognizer Extensions
public extension UIView {
    
    /**
     * Adds a tap gesture to the view with a block that will be invoked whenever
     * the gesture's state changes, e.g., when a tap completes.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The tap gesture.
     */
    public func tapped(_ callback: @escaping (UIGestureRecognizer) -> ()) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer().any(callback)
        addGestureRecognizer(tap)
        return tap as! UITapGestureRecognizer
    }
    
    /**
     * Adds a pinch gesture to the view with a block that will be invoked
     * whenever the gesture's state changes.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The pinch gesture.
     */
    public func pinched(_ callback: @escaping (UIGestureRecognizer) -> ()) -> UIPinchGestureRecognizer {
        let pinch = UIPinchGestureRecognizer().any(callback)
        addGestureRecognizer(pinch)
        return pinch as! UIPinchGestureRecognizer
    }
    
    /**
     * Adds a pan gesture to the view with a block that will be invoked whenever
     * the gesture's state changes.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The pan gesture.
     */
    public func panned(_ callback: @escaping (UIGestureRecognizer) -> ()) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer().any(callback)
        addGestureRecognizer(pan)
        return pan as! UIPanGestureRecognizer
    }
    
    /**
     * Adds a swipe gesture to the view with a block that will be invoked
     * whenever the gesture's state changes, e.g., when a swipe completes.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The swipe gesture.
     */
    public func swiped(_ callback: @escaping (UIGestureRecognizer) -> ()) -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer().any(callback)
        addGestureRecognizer(swipe)
        return swipe as! UISwipeGestureRecognizer
    }
    
    /**
     * Adds a rotation gesture to the view with a block that will be invoked
     * whenever the gesture's state changes.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The rotation gesture.
     */
    public func rotated(_ callback: @escaping (UIGestureRecognizer) -> ()) -> UIRotationGestureRecognizer {
        let rotation = UIRotationGestureRecognizer().any(callback)
        addGestureRecognizer(rotation)
        return rotation as! UIRotationGestureRecognizer
    }
    
    /**
     * Adds a long-press gesture to the view with a block that will be invoked
     * whenever the gesture's state changes, e.g., when a tap completes.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The long-press gesture.
     */
    public func longPressed(_ callback: @escaping (UIGestureRecognizer) -> ()) -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer().any(callback)
        addGestureRecognizer(longPress)
        return longPress as! UILongPressGestureRecognizer
    }
}
