//
//  Tags.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

//Keeping this model for now because I (Daniel Jones) am kind of dumb. When we got a 100 users, the production app was still using this data model. So, now I have to wait for the users to come back into the app to transfer their tags to the new data model. So, until that happens, we need to keep this data model in the app ;(
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




