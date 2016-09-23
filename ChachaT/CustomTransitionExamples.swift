//
//  CustomTransitionExamples.swift
//  MagicMove
//
//  Created by Patrick Reynolds on 1/24/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit

// MARK: Fade Transition
class FadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 1.0
    let originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        containerView.addSubview(toView)
        toView.alpha = 0.0
        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
        })
    }
}

// MARK: Spin Transition

enum SpinTransitionConstants: String {
    
    case BasicAnimationKeyPath
    case RotationAnimationKey
    
    var value: String {
        switch self {
        case .BasicAnimationKeyPath: return "transform.rotation.z"
        case .RotationAnimationKey:  return "rotationAnimation"
        }
    }
}

class SpinTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.5
    let originFrame = CGRect.zero
    let rotations = 1.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        toView.alpha = 0.0
        
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        spinView(view: fromView, duration: duration, rotations: rotations)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            fromView.alpha = 0.0
            toView.alpha = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
        })
    }
    
    // Private Helpers
    private func spinView(view: UIView, duration: TimeInterval, rotations: Double) {
        let rotationAnimation = CABasicAnimation(keyPath: SpinTransitionConstants.BasicAnimationKeyPath.value)
        rotationAnimation.toValue = Double(M_PI) * rotations * 2.0
        rotationAnimation.duration = duration
        rotationAnimation.isCumulative = true
        
        view.layer.add(rotationAnimation, forKey: SpinTransitionConstants.RotationAnimationKey.value)
    }
}
