//
//  UIGestureRecognizerExt.swift
//  MagicMove
//
//  Created by Patrick Reynolds on 1/24/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit

// MARK: - Evented Protocol
public protocol Evented {
    
    func any(_ callback: (Self) -> ()) -> Self
    
    func on(_ state: UIGestureRecognizerState, _ callback: (Self) -> ()) -> Self
    
    func on(_ states: [UIGestureRecognizerState], _ callback: (Self) -> ()) -> Self
    
}

// MARK: UITapGestureRecognizer
extension UITapGestureRecognizer: Evented {
    
    /**
     * Takes a callback that will be invoked upon any gesture recognizer state
     * change, returning the gesture itself.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func any(_ callback: (UITapGestureRecognizer) -> ()) -> Self {
        return on(Any, callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state change, returning the gesture itself.
     *
     * - parameter state: The state upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ state: UIGestureRecognizerState, _ callback: @escaping (UITapGestureRecognizer) -> ()) -> Self {
        return on([state], callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state changes, returning the gesture itself.
     *
     * - parameter states: The states upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ states: [UIGestureRecognizerState], _ callback: @escaping (UITapGestureRecognizer) -> ()) -> Self {
        let responder = Responder(gesture: self)
        responder.on(states) { tap in
            if let tap = tap as? UITapGestureRecognizer {
                callback(tap)
            }
        }
        return self
    }
    
}

// MARK: UIPinchGestureRecognizer
extension UIPinchGestureRecognizer: Evented {
    
    /**
     * Takes a callback that will be invoked upon any gesture recognizer state
     * change, returning the gesture itself.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func any(_ callback: (UIPinchGestureRecognizer) -> ()) -> Self {
        return on(Any, callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state change, returning the gesture itself.
     *
     * - parameter state: The state upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ state: UIGestureRecognizerState, _ callback: @escaping (UIPinchGestureRecognizer) -> ()) -> Self {
        return on([state], callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state changes, returning the gesture itself.
     *
     * - parameter states: The states upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ states: [UIGestureRecognizerState], _ callback: @escaping (UIPinchGestureRecognizer) -> ()) -> Self {
        let responder = Responder(gesture: self)
        responder.on(states) { pinch in
            if let pinch = pinch as? UIPinchGestureRecognizer {
                callback(pinch)
            }
        }
        return self
    }
    
}

// MARK: UIPanGestureRecognizer
extension UIPanGestureRecognizer: Evented {
    
    /**
     * Takes a callback that will be invoked upon any gesture recognizer state
     * change, returning the gesture itself.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func any(_ callback: (UIPanGestureRecognizer) -> ()) -> Self {
        return on(Any, callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state change, returning the gesture itself.
     *
     * - parameter state: The state upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ state: UIGestureRecognizerState, _ callback: @escaping (UIPanGestureRecognizer) -> ()) -> Self {
        return on([state], callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state changes, returning the gesture itself.
     *
     * - parameter states: The states upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ states: [UIGestureRecognizerState], _ callback: @escaping (UIPanGestureRecognizer) -> ()) -> Self {
        let responder = Responder(gesture: self)
        responder.on(states) { pan in
            if let pan = pan as? UIPanGestureRecognizer {
                callback(pan)
            }
        }
        return self
    }
    
}

// MARK: UISwipeGestureRecognizer
extension UISwipeGestureRecognizer: Evented {
    
    /**
     * Takes a callback that will be invoked upon any gesture recognizer state
     * change, returning the gesture itself.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func any(_ callback: (UISwipeGestureRecognizer) -> ()) -> Self {
        return on(Any, callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state change, returning the gesture itself.
     *
     * - parameter state: The state upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ state: UIGestureRecognizerState, _ callback: @escaping (UISwipeGestureRecognizer) -> ()) -> Self {
        return on([state], callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state changes, returning the gesture itself.
     *
     * - parameter states: The states upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ states: [UIGestureRecognizerState], _ callback: @escaping (UISwipeGestureRecognizer) -> ()) -> Self {
        let responder = Responder(gesture: self)
        responder.on(states) { swipe in
            if let swipe = swipe as? UISwipeGestureRecognizer {
                callback(swipe)
            }
        }
        return self
    }
    
}

// MARK: UIRotationGestureRecognizer
extension UIRotationGestureRecognizer: Evented {
    
    /**
     * Takes a callback that will be invoked upon any gesture recognizer state
     * change, returning the gesture itself.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func any(_ callback: (UIRotationGestureRecognizer) -> ()) -> Self {
        return on(Any, callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state change, returning the gesture itself.
     *
     * - parameter state: The state upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ state: UIGestureRecognizerState, _ callback: @escaping (UIRotationGestureRecognizer) -> ()) -> Self {
        return on([state], callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state changes, returning the gesture itself.
     *
     * - parameter states: The states upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ states: [UIGestureRecognizerState], _ callback: @escaping (UIRotationGestureRecognizer) -> ()) -> Self {
        let responder = Responder(gesture: self)
        responder.on(states) { rotation in
            if let rotation = rotation as? UIRotationGestureRecognizer {
                callback(rotation)
            }
        }
        return self
    }
    
}

// MARK: UILongPressGestureRecognizer
extension UILongPressGestureRecognizer: Evented {
    
    /**
     * Takes a callback that will be invoked upon any gesture recognizer state
     * change, returning the gesture itself.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func any(_ callback: (UILongPressGestureRecognizer) -> ()) -> Self {
        return on(Any, callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state change, returning the gesture itself.
     *
     * - parameter state: The state upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ state: UIGestureRecognizerState, _ callback: @escaping (UILongPressGestureRecognizer) -> ()) -> Self {
        return on([state], callback)
    }
    
    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state changes, returning the gesture itself.
     *
     * - parameter states: The states upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    public func on(_ states: [UIGestureRecognizerState], _ callback: @escaping (UILongPressGestureRecognizer) -> ()) -> Self {
        let responder = Responder(gesture: self)
        responder.on(states) { longpress in
            if let longpress = longpress as? UILongPressGestureRecognizer {
                callback(longpress)
            }
        }
        return self
    }
    
}

private let `Any`: [UIGestureRecognizerState] = [.possible, .began, .cancelled, .changed, .ended, .failed]

private let responders = NSMapTable.weakToStrongObjects()

class Responder: NSObject, UIGestureRecognizerDelegate {
    
    var callbacks: [UIGestureRecognizerState: [(UIGestureRecognizer) -> ()]] = [
        .possible: [],
        .began: [],
        .cancelled: [],
        .changed: [],
        .ended: [],
        .failed: []
    ]
    
    init(gesture: UIGestureRecognizer) {
        super.init()
        responders.setObject(self, forKey: gesture)
        gesture.addTarget(self, action: #selector(Responder.recognized(_:)))
        gesture.delegate = self
    }
    
    func on(_ states: [UIGestureRecognizerState], _ callback: @escaping (UIGestureRecognizer) -> ()) {
        for state in states {
            callbacks[state]?.append(callback)
        }
    }
    
    @objc func recognized(_ gesture: UIGestureRecognizer) {
        for callback in callbacks[gesture.state]! {
            callback(gesture)
        }
    }
}
