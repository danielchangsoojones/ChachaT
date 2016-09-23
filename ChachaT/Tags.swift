//
//  Tag.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/5/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

//I tried to create a tag class where each row was its own tag. The problem with this is that trying to query something like Blonde and Democrat required like 3 ineffecient queries. I thought for days of ways to keep it in the individual tag data model, but I could not find a better way. Currently, we just attatch tags to each user and grow it out like an array. It is not the most scalable thing, but every cell in parse has 128kb storage, which is like 20,000 characters. So, thats like 2000 tags, which would be crazy if the average user had. And, if users are inputing that many tags, then we probably shouldn't be using Parse as our backend any longer.
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
    @NSManaged var birthDate: Date?
    @NSManaged var location: PFGeoPoint
}
