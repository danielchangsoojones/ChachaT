//
//  Tag.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/5/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class Tag: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "Tag"
    }
    
    @NSManaged var createdBy: User?
    @NSManaged var title: String
    
    override init() {
        super.init()
    }
    
}
