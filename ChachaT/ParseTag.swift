//
//  ParseTag.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

public enum TagAttributes: String {
    //The string raw values are what will be saved to Parse. DO NOT CHANGE UNLESS YOU CHANGE ALL THE NAMES IN PARSE
    case generic = "generic"
    case dropDownMenu = "dropDownMenu"
    case innerText
}

class ParseTag: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "ParseTag"
    }
    
    //TODO: make enums to hold these
    @NSManaged private var title: String
    @NSManaged var attribute: String //i.e. DropDownTag, Generic, etc. We get thses from our Tag Attribute enum raw value.
    @NSManaged var dropDownCategory: DropDownCategory? //stores the data for what happens if the tag needs to have an action for the dropDownMenu (slider, tag menu, etc.)
    //We want to save all tagTitles as lowercase values, so it will be quick and easy to query over them. But, when using an NSManaged variable, we can't use a setter/getter. So, we made tagTitle a public property that sets the private title variable.
    var tagTitle: String {
        get {
            return title
        }
        set (newStr) {
            title = ParseTag.formatTitleForDatabase(title: newStr)
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(title: String, attribute: TagAttributes, dropDownCategory: DropDownCategory? = nil) {
        self.init()
        self.tagTitle = title
        self.attribute = attribute.rawValue
        self.dropDownCategory = dropDownCategory
    }
    
    class func formatTitleForDatabase(title: String) -> String {
        let withoutEndingWhiteSpacesString = ParseTag.removeEndingSpaces(str: title)
        return withoutEndingWhiteSpacesString.lowercased()
    }
    
    //Purpose: we don't want people to add "hi" and "hi " to the database
    class func removeEndingSpaces(str: String) -> String {
        var characters = str.characters
        if let lastChar = str.characters.last, lastChar == " " {
            //using recursion to remove any ending whitespaces until we hit a non-space character
            characters.removeLast()
            let truncatedString: String = String(characters)
            
            return removeEndingSpaces(str: truncatedString)
        }
        return str
    }
    
    class func findParseTag(title: String, parseTags: [ParseTag]) -> ParseTag? {
        let parseTag = parseTags.first { (parseTag: ParseTag) -> Bool in
            return ParseTag.formatTitleForDatabase(title: title) == parseTag.tagTitle
        }
        return parseTag
    }

}
