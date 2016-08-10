//
//  FilterQueryDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

protocol FilterQueryDataStoreDelegate {
    func getSearchDataArray(searchDataArray: [Tag])
    func setChoicesViewTags(tagChoicesDataArray: [Tag])
    func passUserArrayToMainPage(userArray: [User])
}

class FilterQueryDataStore {
    var searchDataArray : [Tag] = [] //tags that will be available for searching
    var tagChoicesDataArray : [Tag] = [] //tags that get added to the choices tag view
    
    var delegate: FilterQueryDataStoreDelegate?
    
    init(delegate: FilterQueryDataStoreDelegate) {
        self.delegate = delegate
        setSearchDataArray()
        setTagsInTagChoicesDataArray()
    }
    
    //TODO; right now, my search is pulling down the entire tag table and then doing search,
    //very ineffecient, and in future, I will have to do server side cloud code.
    //Also, it is pulling down duplicate tag titles, Example: Two Users might have a blonde tag, but for searching purposes, I only need to have one blonde tag. Right now pulling down all tags, which again is ineffecient
    func setSearchDataArray() {
        addSpecialtyTagsToSearchDataArray()
        var alreadyContainsTagArray: [String] = []
        let query = PFQuery(className: "Tag")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                for tag in tags where tag.attribute == TagAttributes.Generic.rawValue {
                    //we only want to pull down generic tags from database to search. The special tags are added on our frontend side.
                    if !alreadyContainsTagArray.contains(tag.title!) {
                        //our string array does not already contain the tag title, so we can add it to our searchable array
                        alreadyContainsTagArray.append(tag.title!)
                        self.searchDataArray.append(tag)
                    }
                    self.delegate?.getSearchDataArray(self.searchDataArray)
                }
            }
        }
    }
    
    //TODO: I bet this breaks when I try to pass something like Race.
    func addSpecialtyTagsToSearchDataArray() {
        for specialtyTagTitle in SpecialtyTagTitles.allValues {
            if let specialtyCategoryTitle = findSpecialtyCategoryTitle(specialtyTagTitle.toString) {
                searchDataArray.append(Tag(specialtyTagTitle: specialtyTagTitle, specialtyCategoryTitle: specialtyCategoryTitle))
            }
        }
    }
    
    func setTagsInTagChoicesDataArray() {
        //adding in generic tags
        //TODO: this is requerying the database every time to do this, it should just get the array once, and then use that.
        //Although this whole function will change because I only want us to get a certain number of tags, and I don't want it to just be random.
        let query = Tag.query()
        query?.whereKey("attribute", equalTo: TagAttributes.Generic.rawValue)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error == nil {
                for tag in objects as! [Tag] {
                    self.tagChoicesDataArray.append(tag)
                }
                self.setSpecialtyTagsIntoDefaultView()
                self.delegate?.setChoicesViewTags(self.tagChoicesDataArray)
            } else {
                print(error)
            }
        })
    }
    
    //Purpose: I want when you first come onto search page, that you see a group of tags already there that you can instantly press
    //I want mostly special tags like "Age Range", "Location", ect. to be there.
    func setSpecialtyTagsIntoDefaultView() {
        for specialtyCategory in SpecialtyCategoryTitles.allCategories {
            tagChoicesDataArray.append(Tag(specialtyCategoryTitle: specialtyCategory))
        }
    }
    
    //Purpose: the user clicked search, so we want to find the users that fit the criteria.
    func findUserArray(chosenTagArrayTitles: [String]) {
        let query = Tag.query()
        //finding all tags that have a title that the user chose for the search
        //TODO: I'll need to do something if 0 people come up
        if !chosenTagArrayTitles.isEmpty {
            query?.whereKey("title", containedIn: chosenTagArrayTitles)
        }
        query?.whereKey("createdBy", notEqualTo: User.currentUser()!)
        query?.includeKey("createdBy")
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error == nil {
                var userArray : [User] = []
                var userDuplicateArray : [User] = []
                for tag in objects as! [Tag] {
                    if !userDuplicateArray.contains(tag.createdBy) {
                        //weeding out an duplicate users that might be added to array. Users that have all tags will come up as many times as the number of tags.
                        //this fixes that
                        userDuplicateArray.append(tag.createdBy)
                        userArray.append(tag.createdBy)
                    }
                }
                self.delegate?.passUserArrayToMainPage(userArray)
            } else {
                print(error)
            }
        })
    }
    
    
    
}

extension FilterQueryViewController : FilterQueryDataStoreDelegate {
    //TODO: for some reason, it would not let me call this setSearchDataArray, only get. Would like to change name to make it better.
    func getSearchDataArray(searchDataArray: [Tag]) {
        self.searchDataArray = searchDataArray
    }
    
    func setChoicesViewTags(tagChoicesDataArray: [Tag]) {
        self.tagChoicesDataArray = tagChoicesDataArray
        loadChoicesViewTags()
    }
    
    func passUserArrayToMainPage(userArray: [User]) {
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: userArray) //passing userArray to the segue
    }
}
