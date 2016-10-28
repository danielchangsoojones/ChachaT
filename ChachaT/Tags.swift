//
//  Tags.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class Tags: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "Tags"
    }
    
    @NSManaged var createdBy: User
    @NSManaged var genericTags: [String]
    @NSManaged var gender: Int
    @NSManaged var ethnicity: Int
    @NSManaged var sexuality: Int
    @NSManaged var politicalGroup: Int
    @NSManaged var hairColor: Int
    @NSManaged var birthDate: NSDate?
    @NSManaged var location: PFGeoPoint
}




