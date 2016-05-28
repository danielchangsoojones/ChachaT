
//
//  ResizableButton.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import UIKit

class ResizableButton: UIButton {
    
    override func intrinsicContentSize() -> CGSize
    {
        let extraHeightCushion : CGFloat = 50
        let extraWidthCushion : CGFloat = 10
        let labelSize = titleLabel?.sizeThatFits(CGSizeMake(self.frame.size.width, CGFloat.max)) ?? CGSizeZero
        let desiredButtonSize = CGSizeMake(labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right + extraWidthCushion, labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom + extraHeightCushion)
        
        return desiredButtonSize
    }
}