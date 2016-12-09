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
        if index == 0 {
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
        } else if index == 1 {
            let horizontalMargin = -self.bounds.width * backgroundCardHorizontalMarginMultiplier
            let width = self.bounds.width * backgroundCardScalePercent
            var height = width * defaultHeightRatio
            if isIphone3by2AR() {
                height = height * 0.72
            }
            return CGRect(x: horizontalMargin, y: 0, width: width, height: height)
        }
        return CGRect.zero
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
            UIView.animate(withDuration: 1.0, animations: {
                //TODO: we want to animate the button to scale larger and smaller as we drag, like bumble.
                overlayIndicator.frame.x = tuple.targetX
                self.changeAlphe(overlayIndicator: overlayIndicator, dragPercentage: dragPercentage)
            }, completion: nil)
        }
    }
    
    fileprivate func changeAlphe(overlayIndicator: UIView, dragPercentage: CGFloat) {
        let maxAlpha: CGFloat = 0.8
        let minAlpha: CGFloat = 0.2
        let alpheDiff = maxAlpha - minAlpha
        overlayIndicator.alpha = alpheDiff * (dragPercentage / 100) + minAlpha
    }
    
    fileprivate func setIndicator(dragPercentage: CGFloat, direction: SwipeResultDirection) -> (overlayIndicator: OverlayIndicatorView?, targetX: CGFloat) {
        var theOverlayIndicator: OverlayIndicatorView?
        var targetX: CGFloat = 0
        let maxThreshold: CGFloat = self.frame.width * 0.5
        let dx = maxThreshold * (dragPercentage / 100)
        switch direction {
        case .left:
            theOverlayIndicator = theLeftOverlayIndicator
            targetX = dx - theOverlayIndicator!.originalFrame.width
        case .right:
            theOverlayIndicator = theRightOverlayIndicator
            targetX = ez.screenWidth - dx
        default:
            break
        }
        return (theOverlayIndicator, targetX)
    }
    
    func revertToOriginalIndicatorPositions() {
        theLeftOverlayIndicator?.revertToOriginalPosition()
        theRightOverlayIndicator?.revertToOriginalPosition()
    }
}
