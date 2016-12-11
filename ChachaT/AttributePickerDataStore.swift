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
    func save(selection: String, sectionTitle: String) {
        switch sectionTitle {
        case EditProfileConstants.genderTitle:
            saveGender(gender: selection)
        case EditProfileConstants.interestedInTitle:
            saveInterestedIn(interestedIn: selection)
        default:
            break
        }
    }
    
    fileprivate func saveInterestedIn(interestedIn: String) {
        let settingsDataStore = SettingsDataStore()
        settingsDataStore.saveInterestedIn(choice: interestedIn)
    }
}

//saving Gender
extension AttributePickerDataStore {
    func saveGender(gender: String) {
        replaceGenderTag(gender: gender)
    }
    
    fileprivate func replaceGenderTag(gender: String) {
        deletePreviousGenderTag(gender: gender)
        saveTag(gender: gender)
    }
    
    func deletePreviousGenderTag(gender: String) {
        if let previousGender = User.current()!.gender {
            User.current()!.remove(previousGender, forKey: "tagsArray")
            User.current()!.saveInBackground()
            let query = ParseUserTag.query()! as! PFQuery<ParseUserTag>
            query.whereKey("tagTitle", equalTo: previousGender)
            query.getFirstObjectInBackground(block: { (parseUserTag, error) in
                if let parseUserTag = parseUserTag {
                    parseUserTag.deleteInBackground()
                } else if let error = error {
                    print(error)
                }
            })
        }
    }
    
    fileprivate func saveTag(gender: String) {
        let query = ParseTag.query()! as! PFQuery<ParseTag>
        query.whereKey("title", equalTo: gender)
        query.whereKey("attribute", equalTo: TagAttributes.dropDownMenu.rawValue)
        query.getFirstObjectInBackground { (parseTag, error) in
            if let parseTag = parseTag {
                let parseUserTag = ParseUserTag(parseTag: parseTag, isPending: false, approved: true)
                User.current()!.gender = gender
                let addingTagsDataStore = AddingTagsDataStore()
                addingTagsDataStore.saveParseUserTag(parseUserTag)
            } else if let error = error {
                print(error)
            }
        }
    }
}
