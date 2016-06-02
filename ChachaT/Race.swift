//
//  Race.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class Race: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "Race"
    }
    
    @NSManaged var createdBy: User?
    @NSManaged var questionImage: PFFile?
    @NSManaged var question: String
    @NSManaged var questionDescription: String
    @NSManaged var topAnswer: String?
    
    
    
    override init() {
        super.init()
    }
    
}
