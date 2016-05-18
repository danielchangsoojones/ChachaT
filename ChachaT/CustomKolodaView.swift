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
let defaultTopOffset:CGFloat = 67
let defaultHorizontalOffset:CGFloat = 10
let defaultHeightRatio:CGFloat = 1.25
let defaultHeightRatio3by2:CGFloat = 1.06
let backgroundCardHorizontalMarginMultiplier:CGFloat = 0.25
let backgroundCardScalePercent:CGFloat = 1.5

class CustomKolodaView: KolodaView {
    
    override func frameForCardAtIndex(index: UInt) -> CGRect {
        if index == 0 {
            let topOffset:CGFloat = defaultTopOffset
            let xOffset:CGFloat = defaultHorizontalOffset
            let width = UIScreen.mainScreen().bounds.width - 2 * defaultHorizontalOffset
            var height = width * defaultHeightRatio
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
        return CGRectZero
    }
}
