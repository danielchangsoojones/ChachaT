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
    var annotationTitle: String?
    var specialtyCategory: String {
        didSet {
            self.title = specialtyCategory
        }
    }
    var dropDownAttribute: DropDownAttributes
    var innerTagTitles : [String] = []
    var maxValue : Int = 0
    var minValue : Int = 0
    var suffix : String = "" //the suffix is the thing that goes on the end of a number, e.g. "50 mi". "mi" would be the suffix
    var notSetYet : Bool = false //if the tag has not been set by the user, then we want to show a red exclamation point. So, the user knows to click the tag, and set it somehow.
    var databaseColumnName: String = ""
    
    fileprivate init(specialtyCategory: String, dropDownAttribute: DropDownAttributes, notSetYet: Bool) {
        self.specialtyCategory = specialtyCategory
        self.dropDownAttribute = dropDownAttribute
        self.notSetYet = notSetYet
        super.init(title: specialtyCategory, attribute: .dropDownMenu)
    }
    
    //for creating a tagChoices Drop Down
    convenience init(specialtyCategory: String, innerTagTitles: [String], notSetYet: Bool = false, dropDownAttribute: DropDownAttributes) {
        self.init(specialtyCategory: specialtyCategory, dropDownAttribute: dropDownAttribute, notSetYet: notSetYet)
        self.innerTagTitles = innerTagTitles
    }
    
    //for creating the sliders
    convenience init(specialtyCategory: String, minValue: Int = 0, maxValue: Int, suffix: String, notSetYet: Bool = false, dropDownAttribute: DropDownAttributes) {
        self.init(specialtyCategory: specialtyCategory, dropDownAttribute: dropDownAttribute, notSetYet: notSetYet)
        self.minValue = minValue
        self.maxValue = maxValue
        self.suffix = suffix
    }

}
