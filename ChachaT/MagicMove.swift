//
//  MagicMove.swift
//  MagicMove
//
//  Created by Patrick Reynolds on 1/24/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit

// MARK: - MagicMoveable Protocol
@objc protocol MagicMoveable {
    
    var duration: TimeInterval  { get }
    
    var magicViews: [UIView] { get }
    
    @objc optional var spring: CGFloat { get }
}

//go to MagicMove/patrickReynolds to get more info on how magic Move works. Magic move is for animating between pages. 
// MARK: - MagicMoveTransition Delegate
class MagicMoveTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Delegate Properties
    let duration: TimeInterval
    let spring: CGFloat
    
    let from: MagicMoveable
    let to: MagicMoveable
    
    var fromViews: [UIView] {
        return from.magicViews
    }
    
    var toViews: [UIView] {
        return to.magicViews
    }
    
    // MARK: Initializer(s)
    init(from: MagicMoveable, to: MagicMoveable, duration: TimeInterval, spring: CGFloat) {
        self.from = from
        self.to = to
        self.duration = duration
        self.spring = spring
    }
    
    // MARK: Delegate Methods
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView!
        
        magicAnimationFromViewController(fromVC, toViewController: toVC, containerView: containerView, duration: duration, transitionContext: transitionContext)
    }
    
    fileprivate func magicAnimationFromViewController(_ fromViewController: UIViewController, toViewController: UIViewController, containerView: UIView, duration: TimeInterval, transitionContext: UIViewControllerContextTransitioning) {
        
        assert(self.fromViews.count == self.toViews.count, "The count of fromviews and toviews musts be the same!")
        
        for toView in self.toViews {
            toView.isHidden = true
        }
        
        let snapshots: [UIImageView] = self.fromViews.map {
            let snapshot = UIImageView(image: getImageFromView($0))
            snapshot.frame = containerView.convert($0.frame, from: $0.superview)
            $0.isHidden = true
            return snapshot
        }
        
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.alpha = 0
        containerView.addSubview(toViewController.view)
        
        for view in snapshots {
            containerView.addSubview(view)
        }
        
        containerView.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: spring, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(), animations: {
            toViewController.view.alpha = 1.0
            for (index, toView) in self.toViews.enumerated() {
                snapshots[index].frame = containerView.convert(toView.frame, from: toView.superview)
            }
            }, completion: { _ in
                for (index, toView) in self.toViews.enumerated() {
                    toView.isHidden = false
                    self.fromViews[index].isHidden = false
                    
                    snapshots[index].removeFromSuperview()
                }
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    // Private Helpers
    fileprivate func getImageFromView(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


class CustomTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let transition: UIViewControllerAnimatedTransitioning
    
    init(transition: UIViewControllerAnimatedTransitioning) {
        self.transition = transition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

private var UIViewControllerCustomTransitionDelegateKey = 0

class AnimatedTransitioningBox: NSObject {
    let transitioningDelegate: UIViewControllerTransitioningDelegate
    
    init(transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.transitioningDelegate = transitioningDelegate
    }
}

extension UIViewController {
    var customTransitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            let box = objc_getAssociatedObject(self, &UIViewControllerCustomTransitionDelegateKey) as? AnimatedTransitioningBox
            return box?.transitioningDelegate
        }
        set(newValue) {
            if let newValue = newValue {
                let box = AnimatedTransitioningBox(transitioningDelegate: newValue)
                objc_setAssociatedObject(self, &UIViewControllerCustomTransitionDelegateKey, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.transitioningDelegate = newValue
            }
        }
    }
}

extension UIViewController {
    func presentViewControllerCustomTrasition(_ to: UIViewController, transition: UIViewControllerAnimatedTransitioning, animated: Bool, completed: (() -> ())? = nil) {
        to.customTransitioningDelegate = CustomTransitioningDelegate(transition: transition)
        present(to, animated: animated, completion: completed)
    }
}


extension UIViewController {
    func presentViewControllerMagically<F: UIViewController, T: UIViewController>(_ from: F, to: T, animated: Bool, duration: TimeInterval = 0.3, spring: CGFloat = 1.0, completed: (() -> ())? = nil) where F: MagicMoveable, T: MagicMoveable {
        let transition = MagicMoveTransition(from: from, to: to, duration: duration, spring: spring)
        from.presentViewControllerCustomTrasition(to, transition: transition, animated: animated, completed: completed)
    }
}
