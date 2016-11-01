//
//  CustomKolodaView.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Koloda

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
    
    var customKolodaViewDelegate: CustomKolodaViewDelegate?
    
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
