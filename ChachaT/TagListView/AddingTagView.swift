//
//  AddingTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
//This type of tagView is for when we are in the addingTagViewsToProfilePage, we want to have a special tag view that holds a search bar, so we need to do some special stuff in this class, to make it all work correctly within the TagListView.
class AddingTagView: TagView {
    var searchBarPlaceHolderText: String!
    
    init(searchBarPlaceHolderText: String, textFont: UIFont, paddingX: CGFloat, paddingY: CGFloat, borderWidth: CGFloat, cornerRadius: CGFloat, tagBackgroundColor: UIColor) {
        super.init(frame: CGRectZero)
        self.searchBarPlaceHolderText = searchBarPlaceHolderText
        self.textFont = textFont
        self.paddingX = paddingX
        self.paddingY = paddingY
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.tagBackgroundColor = tagBackgroundColor
        addTextFieldSubview()
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Purpose: the user should be able to type into the tag to find new tags
    func addTextFieldSubview() {
        let searchBar = UITextField()
        self.addSubview(searchBar)
        searchBar.placeholder = searchBarPlaceHolderText
        searchBar.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    //overriding this method because in the superclass (TagView) it is making the intrinsic content size based upon the titleLabel. Well, this tagView does not have a title. It has a search bar inside of it, so we have to make sure the intrinsicContentSize still calculates accordingly.
    override func intrinsicContentSize() -> CGSize {
        var size = searchBarPlaceHolderText.sizeWithAttributes([NSFontAttributeName: textFont])
        size.height = textFont.pointSize + paddingY * 2
        size.width += paddingX * 2
        return size
    }
}
