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
    var innerTagTitles : [String] = []
    var maxValue : Int = 0
    var minValue : Int = 0
    var suffix : String = "" //the suffix is the thing that goes on the end of a number, e.g. "50 mi". "mi" would be the suffix
    var keepPrivate : Bool = false //the user doesn't want anyone searching them on this field.
    var notSetYet : Bool = false //if the tag has not been set by the user, then we want to show a red exclamation point. So, the user knows to click the tag, and set it somehow.
    
    private init(specialtyCategory: String, dropDownAttribute: DropDownAttributes) {
        self.specialtyCategory = specialtyCategory
        self.dropDownAttribute = dropDownAttribute
        super.init(title: specialtyCategory, attribute: .DropDownMenu)
    }
    
    //for creating a tagChoices Drop Down
    convenience init(specialtyCategory: String, innerTagTitles: [String], keepPrivate: Bool = false, notSetYet: Bool = false, dropDownAttribute: DropDownAttributes) {
        self.init(specialtyCategory: specialtyCategory, dropDownAttribute: dropDownAttribute)
        self.innerTagTitles = innerTagTitles
        self.keepPrivate = keepPrivate
        self.notSetYet = notSetYet
    }
    
    //initializer for if we want to make a specialtyTag that has a title that is not named the specialty Category. On the adding tags to profile page, we want to show specialty tags, but if they have already set their ethnicity, then we want to set it, not to Ethnicity, but to "Black", "White", etc.
    convenience init(tagTitle: String, specialtyCategory: String, innerTagTitles: [String], keepPrivate: Bool = false, notSetYet: Bool = false, dropDownAttribute: DropDownAttributes) {
        self.init(specialtyCategory: specialtyCategory, innerTagTitles: innerTagTitles, keepPrivate: keepPrivate, notSetYet: notSetYet, dropDownAttribute: dropDownAttribute)
        self.title = tagTitle
    }
    
    

}