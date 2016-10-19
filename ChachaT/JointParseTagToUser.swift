//
//  JointParseTagToUser.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/13/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class JointParseTagToUser: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "JointParseTagToUser"
    }
    
    //TODO: make enums to hold these
    @NSManaged private var tagTitle: String // we will use this as an index to query on.
    @NSManaged var parseTag: ParseTag
    @NSManaged var user: User
    var lowercaseTagTitle: String {
        get {
            return tagTitle
        }
        set (newStr) {
            tagTitle = newStr.lowercased()
        }
    }
}
