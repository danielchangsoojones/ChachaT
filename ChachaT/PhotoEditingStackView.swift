//
//  PhotoEditingStackView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

class PhotoEditingStackView: UIStackView {
    //Purpose: stackViews usually don't have any intrinsic content size, but for the PhotoEditingView, I need to set the intrinsic content size, so other stackViews can calculate it. 
    //This sets the intrinsicContentSize of stackView to the size of its subviews largest intrinsicContentSize
    override var intrinsicContentSize : CGSize {
        var intrinsicWidth: CGFloat = 0
        var intrinsicHeight: CGFloat = 0
        
        for subview in arrangedSubviews {
            //For the respective access, we want to set the corresponding intrinsicContentSize dimension to grow as subviews are added, but the other dimension us just equal to the max dimension of the subview
            if axis == .vertical {
                intrinsicHeight += subview.intrinsicContentSize.height
                let isMaxWidth: Bool = subview.intrinsicContentSize.width > intrinsicWidth
                if isMaxWidth {
                    intrinsicWidth = subview.intrinsicContentSize.width
                }
            } else if axis == .horizontal {
                intrinsicWidth += subview.intrinsicContentSize.width
                let isMaxHeight: Bool = subview.intrinsicContentSize.height > intrinsicHeight
                if isMaxHeight {
                    intrinsicHeight = subview.intrinsicContentSize.height
                }
            }
        }
        
        //account for the spacing of a stackview
        if axis == .vertical {
            intrinsicHeight += addSpacing()
        } else if axis == .horizontal {
            intrinsicWidth += addSpacing()
        }
        
        return CGSize(width: intrinsicWidth, height: intrinsicHeight)
    }
    
    fileprivate func addSpacing() -> CGFloat {
        let numberOfSpaces = arrangedSubviews.count - 1
        return CGFloat(numberOfSpaces) * spacing
    }
}
