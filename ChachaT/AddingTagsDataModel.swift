//
//  AddingTagsDataModel.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class AddingTagsDataStore {
    var genericTagChoicesDataArray : [String] = [] //tags that get added to the choices tag view
    var specialtyTagChoicesDataArray : [SpecialtyTagTitles] = [] //specialty tags that get added to the choices tag view. Need to have an int array to differentiate between the None types
    
    var delegate: AddingTagsDataStoreDelegate?
    
    init(delegate: AddingTagsDataStoreDelegate) {
        self.delegate = delegate
        loadCurrentUserTags()
    }
    
    func loadCurrentUserTags() {
        let query = Tags.query()!
        query.whereKey("createdBy", equalTo: User.currentUser()!)
        //can use FirstObject because there really should only be one result returned anyway.
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if let tag = object as? Tags where error == nil {
                self.loadCurrentUserSpecialtyTags(tag)
                self.delegate?.setChoicesViewTags(self.genericTagChoicesDataArray, specialtyTagChoicesDataArray: self.specialtyTagChoicesDataArray)
            } else {
                print(error)
            }
        }
    }
    
    //TODO: I have to manually add every new specialty category, somehow it should be able to use the Parse names from the Tag enum, and just get all of them
    //TODO: do nil checks on these
    private func loadCurrentUserSpecialtyTags(tag: Tags) {
        specialtyTagChoicesDataArray.append(SpecialtyTagTitles(rawValue: tag.ethnicity)!)
        specialtyTagChoicesDataArray.append(SpecialtyTagTitles(rawValue: tag.hairColor)!)
        specialtyTagChoicesDataArray.append(SpecialtyTagTitles(rawValue: tag.gender)!)
        specialtyTagChoicesDataArray.append(SpecialtyTagTitles(rawValue: tag.politicalGroup)!)
        specialtyTagChoicesDataArray.append(SpecialtyTagTitles(rawValue: tag.sexuality)!)
    }
    
    //TODO: Doing 2 API calls to delete this tag. Plus, it has an API call for every tag deleted, should delete all at once. so it is probably best to figure out how to optimize this..
    //Delete Tag will only be used by generic tags because it is not possible to delete a specialty tag. If you click on a specialty tag, it just pulls drop down menu, and you can change it.
    func deleteTag(title: String) {
        let query = Tags.query()!
        query.whereKey("createdBy", equalTo: User.currentUser()!)
        //can use FirstObject because there really should only be one result returned anyway.
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if let tag = object as? Tags where error == nil {
                //I could just do removeObject, which would only remove the first object found. Technically, there should be only one anyway, but this removes any occurence, so I guess if duplicates somehow got into the database. This would kind of self-clean it
                tag.removeObjectsInArray([title], forKey: "genericTags")
                tag.saveInBackground()
                self.delegate?.deleteTagView(title)
            } else {
                print(error)
            }
        }
    }
}

protocol AddingTagsDataStoreDelegate {
    func deleteTagView(title: String)
    func setChoicesViewTags(genericTagChoicesDataArray: [String], specialtyTagChoicesDataArray : [SpecialtyTagTitles])
}

extension AddingTagsToProfileViewController: AddingTagsDataStoreDelegate {
    func deleteTagView(title: String) {
        tagChoicesView.removeTag(title)
    }
    
    func setChoicesViewTags(genericTagChoicesDataArray: [String], specialtyTagChoicesDataArray : [SpecialtyTagTitles]) {
        self.tagChoicesDataArray = genericTagChoicesDataArray
        self.specialtyTagChoicesDataArray = specialtyTagChoicesDataArray
        loadChoicesViewTags()
    }
}