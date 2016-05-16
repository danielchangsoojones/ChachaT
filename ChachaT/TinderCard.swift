//
//  TinderCard.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/16/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class TinderCard: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "TinderCard"
    }
    
    @NSManaged var createdBy: User?
    @NSManaged var profileImage: PFFile?
    
    override init() {
        super.init()
    }
    
}
