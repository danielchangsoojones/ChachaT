//
//  DropDownTagView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class DropDownTagView: SpecialtyTagView {
    var specialtyCategoryTitle : String = ""
    
    init(tagTitle: String, specialtyCategoryTitle: String) {
        super.init(tagTitle: tagTitle, tagAttribute: .dropDownMenu)
        self.specialtyCategoryTitle = specialtyCategoryTitle
    }
    
    func makeNonPrivate() {
        annotationView?.updateImage(AnnotationImages.dropDownMenu)
    }
    
    func makePrivate() {
        annotationView?.updateImage(AnnotationImages.isPrivate)
        titleEdgeInsets.left = annotationView!.intrinsicContentSize.width + paddingX
        if let tagListView = findSuperTagListView() {
            tagListView.layoutSubviews()
        }
    }
    
    //Purpose: goes through the superviews of the tagView to find the TagListView
    func findSuperTagListView() -> TagListView? {
        var view: UIView? = self
        while (view?.superview != nil) {
            if let tagListView = view?.superview as? TagListView {
                return tagListView
            }
            view = view?.superview
        }
        return nil
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
