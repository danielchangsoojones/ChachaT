//
//  CustomKolodaView.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Koloda
import EZSwiftExtensions

let defaultBottomOffset:CGFloat = 0
let defaultTopOffset:CGFloat = 5
let defaultHorizontalOffset:CGFloat = 10
let defaultHeightRatio:CGFloat = 1.35
let defaultHeightRatio3by2:CGFloat = 1.06
let backgroundCardHorizontalMarginMultiplier:CGFloat = 0.25
let backgroundCardScalePercent:CGFloat = 1.5

protocol CustomKolodaViewDelegate: KolodaViewDelegate  {
    func calculateKolodaViewCardHeight() -> (cardHeight: CGFloat, navigationAreaHeight: CGFloat)
}

class CustomKolodaView: KolodaView {
    var theLeftOverlayIndicator: OverlayIndicatorView?
    var theRightOverlayIndicator: OverlayIndicatorView?
    
    var customKolodaViewDelegate: CustomKolodaViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createOverlayIndicators()
    }
    
    override func frameForCard(at index: Int) -> CGRect {
        let measurmentTuple = customKolodaViewDelegate?.calculateKolodaViewCardHeight()
        let cardHeight = measurmentTuple?.cardHeight
        let navigationAreaHeight = measurmentTuple?.navigationAreaHeight
        
        let topOffset:CGFloat = navigationAreaHeight! + defaultTopOffset
        let xOffset:CGFloat = defaultHorizontalOffset
        let width = UIScreen.main.bounds.width - 2 * defaultHorizontalOffset
        var height = cardHeight! - defaultTopOffset //if we move the card down, then we need to make it that much shorter, so it doesn't go over buttons
        if isIphone3by2AR() {
            height = height * 0.72
        }
        let yOffset:CGFloat = topOffset
        let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        
        return frame
    }
}

//overlay indicator extension
extension CustomKolodaView {
    fileprivate func createOverlayIndicators() {
        theLeftOverlayIndicator = createOverlayIndicator(side: .left)
        theRightOverlayIndicator = createOverlayIndicator(side: .right)
    }
    
    fileprivate func createOverlayIndicator(side: SwipeResultDirection) -> OverlayIndicatorView {
        let overlayIndicatorView = OverlayIndicatorView(side: side == .left ? .left : .right)
        self.addSubview(overlayIndicatorView)
        return overlayIndicatorView
    }
    
    func animate(to dragPercentage: CGFloat, direction: SwipeResultDirection) {
        let tuple = setIndicator(dragPercentage: dragPercentage, direction: direction)
        if let overlayIndicator = tuple.overlayIndicator {
            UIView.animate(withDuration: 0.1, animations: {
                //TODO: we want to animate the button to scale larger and smaller as we drag, like bumble.
                overlayIndicator.frame = tuple.newFrame
                self.changeAlpha(overlayIndicator: overlayIndicator, dragPercentage: dragPercentage)
            }, completion: nil)
        }
    }
    
    fileprivate func changeAlpha(overlayIndicator: UIView, dragPercentage: CGFloat) {
        let maxAlpha: CGFloat = 0.8
        let minAlpha: CGFloat = 0.2
        let alpheDiff = maxAlpha - minAlpha
        overlayIndicator.alpha = alpheDiff * (dragPercentage / 100) + minAlpha
    }
    
    fileprivate func setIndicator(dragPercentage: CGFloat, direction: SwipeResultDirection) -> (overlayIndicator: OverlayIndicatorView?, newFrame: CGRect) {
        var theOverlayIndicator: OverlayIndicatorView?
        var newFrame: CGRect = CGRect.zero
        
        switch direction {
        case .left:
            theOverlayIndicator = theLeftOverlayIndicator
        case .right:
            theOverlayIndicator = theRightOverlayIndicator
        default:
            break
        }
        
        if let theOverlayIndicator = theOverlayIndicator {
            newFrame = getNewIndicatorFrame(indicator: theOverlayIndicator, progress: dragPercentage / 100)
        }
        
        return (theOverlayIndicator, newFrame)
    }
    
    fileprivate func getNewIndicatorFrame(indicator: OverlayIndicatorView, progress: CGFloat) -> CGRect {
        let originalFrame = indicator.originalFrame
        let maxFrame = indicator.maxFrame
        let targetX = alterFrame(initial: originalFrame.x, final: maxFrame.x, progress: progress)
        let targetY = alterFrame(initial: originalFrame.y, final: maxFrame.y, progress: progress)
        let targetWidth = alterFrame(initial: originalFrame.width, final: maxFrame.width, progress: progress)
        let targetHeight = alterFrame(initial: originalFrame.height, final: maxFrame.height, progress: progress)
        return CGRect(x: targetX, y: targetY, w: targetWidth, h: targetHeight)
    }
    
    fileprivate func alterFrame(initial: CGFloat, final: CGFloat, progress: CGFloat) -> CGFloat {
        return (final - initial) * progress + initial
    }
    
    func revertToOriginalIndicatorPositions() {
        theLeftOverlayIndicator?.revertToOriginalPosition()
        theRightOverlayIndicator?.revertToOriginalPosition()
    }
}
