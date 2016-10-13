//
//  TagEnums.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/14/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//
import Parse

//just using this class to hold the stuff I want to create in the database. I should eventually put this in a unit tests section because we don't really need this in the actual project code.
class holder {
    init() {}
    
    func createAllDatabaseTags() {
        let query = DropDownCategory.query()! as! PFQuery<DropDownCategory>
        query.whereKey("type", equalTo: DropDownAttributes.tagChoices.rawValue)
        query.findObjectsInBackground { (categories, error) in
            if let categories = categories {
                for dropDownCategory in categories {
                    for tagTitle in dropDownCategory.innerTagTitles {
                        let parseTag = ParseTag()
                        parseTag.title = tagTitle
                        parseTag.attribute = TagAttributes.dropDownMenu.rawValue
                        parseTag.isPrivate = false
                        parseTag.dropDownCategory = dropDownCategory
                    }
                }
            }
        }
    }
    
    func createPointersArrayForDropDownCategory() {
        let query = DropDownCategory.query()!
        query.whereKey("type", equalTo: DropDownAttributes.tagChoices.rawValue)
        query.findObjectsInBackground { (objects, error) in
            if let categories = objects as? [DropDownCategory] {
                for category in categories {
                        let query = ParseTag.query()!
                        query.whereKey("title", containedIn: category.innerTagTitles)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if let parseTags = objects as? [ParseTag] {
                                for parseTag in parseTags {
                                    category.addUniqueObject(parseTag, forKey: "innerTags")
                                    category.saveInBackground()
                                }
                            }
                        })
                }
            }
        }
    }
    
    func createSliderCategories() {
        DropDownCategory().createNewSliderCategory(name: "Distance", parseColumnName: "location", min: 0, max: 50, suffix: "mi", isSingleSlider: true)
        DropDownCategory().createNewSliderCategory(name: "Age Range", parseColumnName: "birthDate", min: 18, max: 65, suffix: "yrs", isSingleSlider: false)
    }
}


