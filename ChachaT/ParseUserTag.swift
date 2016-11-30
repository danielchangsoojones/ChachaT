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
    @NSManaged var createdBy: User
    @NSManaged var isPending: Bool
    @NSManaged var approved: Bool
    var lowercasedTagTitle: String {
        get {
            return tagTitle
        }
        set (str) {
            self.tagTitle = str.lowercased()
        }
    }
    
    override init() {
        //have to override init, or else Parse gets mad.
        super.init()
    }
    
    convenience init(parseTag: ParseTag, user: User = User.current()!, isPending: Bool, approved: Bool) {
        self.init()
        self.parseTag = parseTag
        self.user = user
        self.lowercasedTagTitle = parseTag.tagTitle
        self.createdBy = User.current()!
        self.isPending = isPending
        self.approved = approved
    }
}
