//
//  Answer.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/25/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class Answer: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "Answer"
    }
    
    @NSManaged var createdBy: User?
    @NSManaged var questionImage: PFFile?
    @NSManaged var answer: String
    @NSManaged var questionParent: Question?
    
    override init() {
        super.init()
    }
    
}
