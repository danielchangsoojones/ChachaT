//
//  FilterQueryDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse
import SCLAlertView

protocol FilterQueryDataStoreDelegate {
    func getSearchDataArray(searchDataArray: [String])
    func setChoicesViewTags(tagChoicesDataArray: [String])
    func passUserArrayToMainPage(userArray: [User])
}

class FilterQueryDataStore {
    var searchDataArray : [String] = [] //tags that will be available for searching
    var tagChoicesDataArray : [String] = [] //tags that get added to the choices tag view
    
    var delegate: FilterQueryDataStoreDelegate?
    
    init(delegate: FilterQueryDataStoreDelegate) {
        self.delegate = delegate
        setSearchDataArray()
        setSpecialtyTagsIntoDefaultView()
    }
    
    //TODO; right now, my search is pulling down the entire tag table and then doing search,
    //very ineffecient, and in future, I will have to do server side cloud code.
    //Also, it is pulling down duplicate tag titles, Example: Two Users might have a blonde tag, but for searching purposes, I only need to have one blonde tag. Right now pulling down all tags, which again is ineffecient
    func setSearchDataArray() {
        addSpecialtyTagsToSearchDataArray()
        var alreadyContainsTagArray: [String] = []
        let query = Tags.query()
        query!.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let tags = objects as? [Tags] {
                for tag in tags {
                    for tagTitle in tag.genericTags {
                        if !alreadyContainsTagArray.contains(tagTitle) {
                            //our string array does not already contain the tag title, so we can add it to our searchable array
                            alreadyContainsTagArray.append(tagTitle)
                            self.searchDataArray.append(tagTitle)
                        }
                    }
                    self.delegate?.getSearchDataArray(self.searchDataArray)
                }
            }
        }
    }
    
    //Purpose: we only want to pull down generic tags from database to search. The special tags are added on our frontend side.
    func addSpecialtyTagsToSearchDataArray() {
        for specialtyTagTitle in SpecialtyTagTitles.allValues {
            searchDataArray.append(specialtyTagTitle.toString)
        }
    }
    
    //Purpose: I want when you first come onto search page, that you see a group of tags already there that you can instantly press
    //I want mostly special tags like "Age Range", "Location", ect. to be there.
    func setSpecialtyTagsIntoDefaultView() {
        for specialtyCategory in SpecialtyCategoryTitles.allCategories {
            tagChoicesDataArray.append(specialtyCategory.rawValue)
        }
        delegate?.setChoicesViewTags(tagChoicesDataArray)
    }
    
    //Purpose: the user clicked search, so we want to find the users that fit the criteria.
    func findUserArray(chosenTagArrayTitles: [String]) {
        if !chosenTagArrayTitles.isEmpty {
            let genericTagQuery = Tags.query()
            //need to seperate the generic and specialty tags
            let arraysTuple = filterGenericTagArrayAndSpecialtyTagArray(chosenTagArrayTitles)
            let genericTagTitleArray = arraysTuple.genericTagTitleArray
            let specialtyTagTitleArray = arraysTuple.specialtyTagTitleArray
            if !genericTagTitleArray.isEmpty {
                genericTagQuery!.whereKey("genericTags", containsAllObjectsInArray:genericTagTitleArray)
            }
            let finalQuery = querySpecialtyTags(specialtyTagTitleArray, query: genericTagQuery!)
            finalQuery.whereKey("createdBy", notEqualTo: User.currentUser()!)
            finalQuery.includeKey("createdBy")
            finalQuery.selectKeys(["createdBy"]) //we really only need to know the users
            finalQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
                if let objects = objects where error == nil {
                    if objects.isEmpty {
                        print(objects)
                        SCLAlertView().showInfo("Important info", subTitle: "You are great")
                    } else {
                        var userArray : [User] = []
                        for tag in objects as! [Tags] {
                            userArray.append(tag.createdBy)
                        }
                        self.delegate?.passUserArrayToMainPage(userArray)
                    }
                } else {
                    print(error)
                }
            })
        }
    }
    
    //Purpose: we need to seperate an array for specialty tags becuse the genericTags in Parse will not contain those titles in their array. We need to do special things with those.
    func filterGenericTagArrayAndSpecialtyTagArray(stringArray: [String]) -> (genericTagTitleArray: [String], specialtyTagTitleArray: [String]) {
        var specialtyTagTitleArray : [String] = []
        var genericTagTitleArray : [String] = []
        for tagTitle in stringArray {
            if tagTitleIsSpecial(tagTitle) {
                specialtyTagTitleArray.append(tagTitle)
            } else {
                //the tag is a generic tag
                genericTagTitleArray.append(tagTitle)
            }
        }
        return (genericTagTitleArray, specialtyTagTitleArray)
    }
    
    func querySpecialtyTags(specialtyTagTitleArray: [String], query: PFQuery) -> PFQuery {
        for tagTitle in specialtyTagTitleArray {
            if let specialtyTagTitle = SpecialtyTagTitles.stringRawValue(tagTitle) {
                if let specialtyCategoryTitle = specialtyTagTitle.associatedSpecialtyCategoryTitle {
                    if let tagAttribute = specialtyCategoryTitle.associatedTagAttribute {
                        switch tagAttribute {
                        case .SpecialtyTagMenu:
                            //does a query on the correct column name and also the SpecialtyTagTitle rawValue, which is an int
                            query.whereKey(specialtyCategoryTitle.parseColumnName, equalTo: specialtyTagTitle.rawValue)
                        case .SpecialtySingleSlider:
                            break
                        case .SpecialtyRangeSlider:
                            break
                        }
                    }
                }
            }
        }
        //return the same query after we have added the specialty criteria
        return query
    }
}

extension FilterQueryViewController : FilterQueryDataStoreDelegate {
    //TODO: for some reason, it would not let me call this setSearchDataArray, only get. Would like to change name to make it better.
    func getSearchDataArray(searchDataArray: [String]) {
        self.searchDataArray = searchDataArray
    }
    
    func setChoicesViewTags(tagChoicesDataArray: [String]) {
        self.tagChoicesDataArray = tagChoicesDataArray
        loadChoicesViewTags()
    }
    
    func passUserArrayToMainPage(userArray: [User]) {
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: userArray) //passing userArray to the segue
    }
}
