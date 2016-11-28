//
//  SearchCache.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class SearchCache: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "SearchCache"
    }
    
    @NSManaged var cacheIdentifier: String
    @NSManaged var users: PFRelation<User>
}
