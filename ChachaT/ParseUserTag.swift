//
//  ParseUserTag.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

//A ParseUserTag is the join table between ParseTags and Users tables
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
    
    init(parseTag: ParseTag) {
        super.init()
        self.parseTag = parseTag
        self.user = User.current()!
        self.lowercasedTagTitle = parseTag.tagTitle
    }
}
