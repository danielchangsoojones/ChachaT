//
//  ChachaChoicesTagListView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

struct TagProperties {
    static let borderWidth : CGFloat = 1
    static let borderColor = UIColor.whiteColor()
    static let textColor = UIColor.whiteColor()
    static let tagBackgroundColor = UIColor.clearColor()
    static let cornerRadius : CGFloat = 16
    static let paddingX : CGFloat = 14 //adds horizontal padding on each side of text, so extends width of TagView, but keeps the text centered.
    static let paddingY : CGFloat = 10 //adds vertical padding on each side of text, so extends width of TagView, but keeps the text centered.
    static let marginX : CGFloat = 9 //the horizontal space between TagViews
    static let marginY : CGFloat = 8 //the vertical space between TagViews
}

class ChachaChoicesTagListView : TagListView {
    
    //for some reason, when using IBinspectables, I have to have this init even though only the coder init gets called
    //keep this init despite it seeming to not do anything.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProperties()
    }
    
    func setProperties() {
        borderColor = TagProperties.borderColor
        borderWidth = TagProperties.borderWidth
        textColor = TagProperties.textColor
        tagBackgroundColor = TagProperties.tagBackgroundColor
        cornerRadius = TagProperties.cornerRadius
        paddingX = TagProperties.paddingX //adds horizontal padding on each side of text, so extends width of TagView, but keeps the text centered.
        paddingY = TagProperties.paddingY //adds vertical padding on each side of text, so extends width of TagView, but keeps the text centered.
        marginX = TagProperties.marginX //the horizontal space between TagViews
        marginY = TagProperties.marginY //the vertical space between TagViews
        alignment = .Center //makes the entire TagListView have a centered alignment, this isn't for text alignment
    }

}
