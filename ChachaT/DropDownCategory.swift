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
}
