//
//  AttributePickerDataModel.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class AttributePickerDataStore {
    func saveGender(gender: String) {
        replaceGenderTag(gender: gender)
    }
    
    fileprivate func replaceGenderTag(gender: String) {
        let relation = User.current()!.relation(forKey: "tags")
        
        let innerQuery = DropDownCategory.query()!
        innerQuery.whereKey("name", equalTo: "Gender")
        
        let query = relation.query() as! PFQuery<ParseTag>
        query.whereKey("dropDownCategory", matchesQuery: innerQuery)
        
        query.findObjectsInBackground { (parseTags, error) in
            if let parseTags = parseTags {
                for parseTag in parseTags {
                    relation.remove(parseTag)
                }
            } else if let error = error {
                print(error)
            }
            self.saveNewTagRelation(relation: relation, gender: gender)
        }
    }
    
    fileprivate func saveNewTagRelation(relation: PFRelation<PFObject>, gender: String) {
        let query = ParseTag.query()! as! PFQuery<ParseTag>
        query.whereKey("title", equalTo: gender)
        query.getFirstObjectInBackground { (parseTag, error) in
            if let parseTag = parseTag {
                relation.add(parseTag)
                self.saveUsersGender(gender: gender)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    fileprivate func saveUsersGender(gender: String) {
        User.current()!.gender = gender
        User.current()?.saveInBackground()
    }
    
    
}
