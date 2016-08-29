//
//  AddingTagsDataModel.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class AddingTagsDataStore {
    
    var delegate: AddingTagsDataStoreDelegate?
    
    init(delegate: AddingTagsDataStoreDelegate) {
        self.delegate = delegate
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
}

extension AddingTagsToProfileViewController: AddingTagsDataStoreDelegate {
    func deleteTagView(title: String) {
        tagChoicesView.removeTag(title)
    }
}