//
//  DropDownCategory.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class DropDownCategory: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "DropDownCategory"
    }
    
    @NSManaged var name: String
    @NSManaged var type: String //i.e. range slider, single slider, tag menu. The type is what happens when the dropDownMenu appears.
    @NSManaged var parseColumnName: String?
    //For Tag Menu:
    @NSManaged var innerTags: [ParseTag]?
    //For Sliders:
    @NSManaged var max: Int
    @NSManaged var min: Int
    @NSManaged var suffix: String //i.e. mi or yrs
    var innerTagTitles: [String] {
        get {
            var titleArray: [String] = []
            if let innerTags = innerTags {
                titleArray = innerTags.map({ (parseTag: ParseTag) -> String in
                    return parseTag.tagTitle
                })
            }
            return titleArray
        }
    }
    
    //Purpose: for creating a new DropDownCategory in the database. This should probably go with unit tests or something because we don't need it in the actual code, just makes things easier.
    func createNewTagMenuCategory(name: String, innerTagTitles: [String]) {
        self.name = name
        self.innerTags = innerTagTitles.map({ (title: String) -> ParseTag in
            let parseTag = ParseTag()
            parseTag.tagTitle = title
            parseTag.attribute = TagAttributes.dropDownMenu.rawValue
            parseTag.isPrivate = false
            parseTag.dropDownCategory = self
            return parseTag
        })
        self.type = DropDownAttributes.tagChoices.rawValue
        self.parseColumnName = ""
        self.max = -100
        self.min = -100
        self.suffix = ""
        self.saveInBackground()
    }
    
    func createNewSliderCategory(name:String, parseColumnName: String, min: Int, max: Int, suffix: String, isSingleSlider: Bool) {
        self.name = name
        self.innerTags = nil
        self.type = isSingleSlider ? DropDownAttributes.singleSlider.rawValue : DropDownAttributes.rangeSlider.rawValue
        self.parseColumnName = parseColumnName
        self.max = max
        self.min = min
        self.suffix = suffix
        self.saveInBackground()
    }
}
