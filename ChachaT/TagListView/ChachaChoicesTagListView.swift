//
//  ChachaChoicesTagListView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

struct TagViewProperties {
    static let borderWidth : CGFloat = 1
    static let borderColor = CustomColors.JellyTeal
    static let textColor = CustomColors.JellyTeal
    static let textFont = UIFont.systemFont(ofSize: 16.0)
    static let tagBackgroundColor = UIColor.clear
    static let tagInsidesColor = UIColor.white //the tag insides for the chosen view
    static let cornerRadius : CGFloat = (TagViewProperties.textFont.pointSize + TagViewProperties.paddingY * 2) / 2 //makes the tagView have nice rounded corners, no matter size.
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
        borderColor = TagViewProperties.borderColor
        borderWidth = TagViewProperties.borderWidth
        textColor = TagViewProperties.textColor
        textFont = TagViewProperties.textFont
        tagBackgroundColor = TagViewProperties.tagBackgroundColor
        paddingX = TagViewProperties.paddingX //adds horizontal padding on each side of text, so extends width of TagView, but keeps the text centered.
        paddingY = TagViewProperties.paddingY //adds vertical padding on each side of text, so extends width of TagView, but keeps the text centered.
        marginX = TagViewProperties.marginX //the horizontal space between TagViews
        marginY = TagViewProperties.marginY //the vertical space between TagViews
        alignment = .center //makes the entire TagListView have a centered alignment, this isn't for text alignment
        tagSelectedBackgroundColor = TagViewProperties.borderColor
        selectedTextColor = TagViewProperties.tagInsidesColor
        cornerRadius = TagViewProperties.cornerRadius
    }

}
