//
//  DropDownTag.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

public enum DropDownAttributes {
    case TagChoices
    case SingleSlider
    case RangeSlider
}

class DropDownTag : Tag {
    var specialtyCategory: String
    var dropDownAttribute: DropDownAttributes
    
    init(specialtyCategory: String, dropDownAttribute: DropDownAttributes) {
        self.specialtyCategory = specialtyCategory
        self.dropDownAttribute = dropDownAttribute
        super.init(title: specialtyCategory, attribute: .DropDownMenu)
    }
    
    //initializer for if we want to make a specialtyTag that has a title that is not named the specialty Category. On the adding tags to profile page, we want to show specialty tags, but if they have already set their ethnicity, then we want to set it, not to Ethnicity, but to "Black", "White", etc.
    convenience init(tagTitle: String, specialtyCategory: String, dropDownAttribute: DropDownAttributes) {
        self.init(specialtyCategory: specialtyCategory, dropDownAttribute: dropDownAttribute)
        self.title = tagTitle
    }
}