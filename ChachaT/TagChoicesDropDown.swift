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
        addTags(tagTitles, tagListView: tagListView) //Since, I am adding the tags before I the tagView is added to the screen, the tags have a kind of cool animation. The way to make the tags just appear normally would be to add them after the view/height has been created, but then there are some problems about having the height grow according to the size of the add tags.
        self.innerView = tagListView
        addTagListViewToView(dropDownView, subview: innerView!)
        self.show()
    }
    
    private func addTagListViewToView(superview: UIView, subview: UIView) {
        superview.addSubview(subview)
        subview.snp_makeConstraints { (make) in
            make.trailing.leading.equalTo(superview)
            make.top.equalTo(superview)
            //using low priority because the compiler needs to know which constraints to break when the dropDownHeight is 0
            make.bottom.equalTo(arrowImage.snp_top).offset(-arrowImageInset).priorityLow() //not sure why inset(5) does not work, but it doesn't
        }
    }
    
    private func addTags(titleArray: [String], tagListView: TagListView) {
        for title in titleArray {
            tagListView.addTag(title)
        }
    }
}