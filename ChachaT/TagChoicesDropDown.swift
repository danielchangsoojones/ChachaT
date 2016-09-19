//
//  TagChoicesDropDown.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

//This extension is for when the menu needs to show a TagListView
extension ChachaDropDownMenu {
    func addTagListView(tagTitles: [String], specialtyCategory: String, tagListViewDelegate: TagListViewDelegate) {
        let tagListView = ChachaChoicesTagListView(frame: CGRectMake(0, 0, screenSizeWidth, 0))
        tagListView.delegate = tagListViewDelegate
        tagListView.tag = 3 //need to set this, so I can know which tagView (i.e. tagChosenView = 2, tagChoicesView = 1, dropDownTagView (this) = 3).
        addTags(tagTitles, tagListView: tagListView)
        self.innerView = tagListView
        self.innerView?.frame = CGRect(origin: CGPointZero, size: tagListView.intrinsicContentSize()) //need to set the frame, so the dropDownMenu knows how to calculate the height
        addInnerView()
        self.show()
    }
    
    private func addTags(titleArray: [String], tagListView: TagListView) {
        for title in titleArray {
            tagListView.addTag(title)
        }
    }
}