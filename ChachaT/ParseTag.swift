//
//  ParseTag.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class ParseTag: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "ParseTag"
    }
    
    //TODO: make enums to hold these
    @NSManaged var title: String
    @NSManaged var attribute: String //i.e. DropDownTag, Generic, etc.
    @NSManaged var dropDownCategory: DropDownCategory? //stores the data for what happens if the tag needs to have an action for the dropDownMenu (slider, tag menu, etc.)
    @NSManaged var isPrivate: Bool
}
