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
        var maxSize : CGSize = CGSize.zero
        for subview in arrangedSubviews {
            if subview.intrinsicContentSize.height > maxSize.height && subview.intrinsicContentSize.height > maxSize.height {
                //the size is greatest in both dimensions(height and width). Technically, all views passed to this stack view should have equal heights/widths, so not technically necessary to check both.
                maxSize = subview.intrinsicContentSize
            }
        }
        
        return maxSize
    }
}
