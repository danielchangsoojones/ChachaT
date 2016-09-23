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
    func addTagListView(_ tagTitles: [String], specialtyCategory: String, tagListViewDelegate: TagListViewDelegate) {
        let tagListView = ChachaChoicesTagListView(frame: CGRect(x: 0, y: 0, width: screenSizeWidth, height: 0))
        tagListView.delegate = tagListViewDelegate
        tagListView.tag = 3 //need to set this, so I can know which tagView (i.e. tagChosenView = 2, tagChoicesView = 1, dropDownTagView (this) = 3).
        addTags(tagTitles, tagListView: tagListView)
        self.innerView = tagListView
        addInnerView()
        self.show()
    }
    
    fileprivate func addTags(_ titleArray: [String], tagListView: TagListView) {
        for title in titleArray {
            tagListView.addTag(title)
        }
    }
}
