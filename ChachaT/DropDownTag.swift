//
//  DropDownTag.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

public enum DropDownAttributes: String {
    //the raw values are what will be saved as the type to the API
    case tagChoices = "Tag Menu"
    case singleSlider = "Single Slider"
    case rangeSlider = "Range Slider"
}

//TODO: I can subclass this even farther into tagChoices and sliderTags
class DropDownTag : Tag {
    var displayName: String = "" //when adding tags, we want the properties of something like gender, but have it show Male
    var specialtyCategory: String
    var dropDownAttribute: DropDownAttributes
    var innerTagTitles : [String] = []
    var maxValue : Int = 0
    var minValue : Int = 0
    var suffix : String = "" //the suffix is the thing that goes on the end of a number, e.g. "50 mi". "mi" would be the suffix
    var isPrivate : Bool = false //the user doesn't want anyone searching them on this field.
    var notSetYet : Bool = false //if the tag has not been set by the user, then we want to show a red exclamation point. So, the user knows to click the tag, and set it somehow.
    
    fileprivate init(specialtyCategory: String, dropDownAttribute: DropDownAttributes, isPrivate: Bool, notSetYet: Bool) {
        self.specialtyCategory = specialtyCategory
        self.dropDownAttribute = dropDownAttribute
        self.isPrivate = isPrivate
        self.notSetYet = notSetYet
        super.init(title: specialtyCategory, attribute: .dropDownMenu)
    }
    
    //for creating a tagChoices Drop Down
    convenience init(specialtyCategory: String, innerTagTitles: [String], isPrivate: Bool = false, notSetYet: Bool = false, dropDownAttribute: DropDownAttributes) {
        self.init(specialtyCategory: specialtyCategory, dropDownAttribute: dropDownAttribute, isPrivate: isPrivate, notSetYet: notSetYet)
        self.innerTagTitles = innerTagTitles
    }
    
    //initializer for if we want to make a specialtyTag that has a title that is not named the specialty Category. On the adding tags to profile page, we want to show specialty tags, but if they have already set their ethnicity, then we want to set it, not to Ethnicity, but to "Black", "White", etc.
    convenience init(tagTitle: String, specialtyCategory: String, innerTagTitles: [String], isPrivate: Bool = false, notSetYet: Bool = false, dropDownAttribute: DropDownAttributes) {
        self.init(specialtyCategory: specialtyCategory, innerTagTitles: innerTagTitles, isPrivate: isPrivate, notSetYet: notSetYet, dropDownAttribute: dropDownAttribute)
        self.title = tagTitle
    }
    
    //for creating the sliders
    convenience init(specialtyCategory: String, minValue: Int = 0, maxValue: Int, suffix: String, isPrivate: Bool = false, notSetYet: Bool = false, dropDownAttribute: DropDownAttributes) {
        self.init(specialtyCategory: specialtyCategory, dropDownAttribute: dropDownAttribute, isPrivate: isPrivate, notSetYet: notSetYet)
        self.minValue = minValue
        self.maxValue = maxValue
        self.suffix = suffix
    }

}
