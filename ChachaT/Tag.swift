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
    
    @NSManaged var createdBy: User
    @NSManaged var title: String?
    @NSManaged var specialtyTagTitle: Int
    @NSManaged var specialtyCategoryTitle: Int
    //pre-set to generic, unless the variable is overrided in the initializer
    @NSManaged var attribute: Int
    
    override init() {
        super.init()
    }
    
    //initiliazer for specialty tags with specialty tag titles
    init(specialtyTagTitle: SpecialtyTagTitles, specialtyCategoryTitle: SpecialtyCategoryTitles) {
        super.init()
        self.title = nil
        self.createdBy = User.currentUser()!
        self.specialtyTagTitle = specialtyTagTitle.rawValue
        self.specialtyCategoryTitle = specialtyCategoryTitle.rawValue
        self.attribute = convertTagAttributeFromCategoryTitle(specialtyCategoryTitle).rawValue
    }
    
    //init for tags that only have the category title as their title. Like having a "Race" tag.
    init(specialtyCategoryTitle: SpecialtyCategoryTitles) {
        super.init()
        self.title = nil
        self.createdBy = User.currentUser()!
        self.specialtyTagTitle = -1
        self.specialtyCategoryTitle = specialtyCategoryTitle.rawValue
        self.attribute = convertTagAttributeFromCategoryTitle(specialtyCategoryTitle).rawValue
    }
    
    //initializer for Generic normal tags
    init(title: String) {
        super.init()
        self.title = title
        self.specialtyTagTitle = -1
        self.specialtyCategoryTitle = -1
        self.attribute = TagAttributes.Generic.rawValue
        self.createdBy = User.currentUser()!
    }
    
    //Purpose: figure out if the tag is a special tag
    func isSpecial() -> (specialtyTagTitle: SpecialtyTagTitles, specialtyCategoryTitle: SpecialtyCategoryTitles)? {
        if let specialtyTagTitle = SpecialtyTagTitles(rawValue: self.specialtyTagTitle) {
            if let specialtyCategoryTitle = SpecialtyCategoryTitles(rawValue: self.specialtyCategoryTitle) {
                //we have a specialty tag because both the specialtyTagTitle and specialtyCategoryTitle exists
                return (specialtyTagTitle, specialtyCategoryTitle)
            }
        }
        return nil //it was not a specialty tag, so return nil
    }
    
    //figure out if the tag is generic
    func isGeneric() -> Bool {
        if title != nil {
            //we have a generic tag
            return true
        }
        return false //not a generic tag
    }
    
    //Purpose: the title to show for a tag might be something generic like iOS Developer, special like Brunette, or even just a special category like Race
    func titleToShowForTag() -> String {
        if let tagTitle = title {
            //generic tag, so just return title
            return tagTitle
        } else if let specialtyTagTitle = SpecialtyTagTitles(rawValue: specialtyTagTitle) {
            //a specialty tag that has one of the SpecialtyTagTitles as its title
            //returns something like Brunette
            return specialtyTagTitle.toString
        } else if let specialtyCategoryTitle = SpecialtyCategoryTitles(rawValue: specialtyCategoryTitle) {
            //the tag is special, but the specialtyTagTitle does not exist, only the specialtyTagCategory
            //returns something like Race
            return specialtyCategoryTitle.toString
        }
        //should never reach this point
        return ""
    }
    
}
