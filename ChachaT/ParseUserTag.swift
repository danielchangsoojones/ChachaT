//
//  ParseUserTag.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class ParseUserTag: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "ParseUserTag"
    }
    
    @NSManaged private var tagTitle: String
    @NSManaged var parseTag: ParseTag
    @NSManaged var user: User
    var lowercasedTagTitle: String {
        get {
            return tagTitle
        }
        set (str) {
            self.tagTitle = str.lowercased()
        }
    }
}
