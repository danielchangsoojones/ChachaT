//
//  Match.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/22/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse

class Match: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "Match"
    }
    
    @NSManaged var currentUser : User
    @NSManaged var targetUser : User
    @NSManaged var isMatch : Bool
    @NSManaged var mutualMatch : Bool
}
