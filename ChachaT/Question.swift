//
//  Post.swift
//  Chacha
//
//  Created by Daniel Jones on 3/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class Question: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "Question"
    }
    
    @NSManaged var createdBy: User?
    @NSManaged var questionImage: PFFile?
    @NSManaged var question: String
    @NSManaged var questionDescription: String
    
    
    
    override init() {
        super.init()
    }
    
}