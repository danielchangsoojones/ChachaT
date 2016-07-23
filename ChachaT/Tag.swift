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
    @NSManaged var specialtyCategoryTitle: String?
    //pre-set to generic, unless the variable is overrided in the initializer
    @NSManaged var attribute: String
    
    override init() {
        super.init()
    }
    
    init(title: String, specialtyCategoryTitle: SpecialtyTags?) {
        super.init()
        self.title = title
        self.createdBy = User.currentUser()
        if let specialtyCategoryTitle = specialtyCategoryTitle {
            //the tag is a specialty Tag
            self.specialtyCategoryTitle = specialtyCategoryTitle.rawValue
            self.attribute = convertTagAttributeFromCategoryTitle(specialtyCategoryTitle.rawValue).rawValue
        } else {
            //the tag is a generic tag
            self.attribute = TagAttributes.Generic.rawValue
        }
    }
    
}
