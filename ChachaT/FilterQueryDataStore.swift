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
    func setChoicesViewTags(tagChoicesDataArray: [Tag])
    func passUserArrayToMainPage(userArray: [User])
}

class FilterQueryDataStore {
    var searchDataArray : [String] = [] //tags that will be available for searching
    var tagChoicesDataArray : [Tag] = [] //tags that get added to the choices tag view
    
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
            //TODO: .TagChoices should not be the dropDownAttribute every time. This is just for testing.
            if let dropDownAttribute = specialtyCategory.associatedDropDownAttribute {
                let innerTagTitles : [String] = specialtyCategory.specialtyTagTitles.map{
                    $0.toString
                }
                let dropDownTag = DropDownTag(specialtyCategory: specialtyCategory.rawValue, innerTagTitles: innerTagTitles, dropDownAttribute: dropDownAttribute)
                tagChoicesDataArray.append(dropDownTag)
            }
        }
        delegate?.setChoicesViewTags(tagChoicesDataArray)
    }
    
    func findUserArray(genericTagTitleArray: [String], specialtyTagDictionary: [SpecialtyCategoryTitles : TagView?]) {
        let genericTagQuery = Tags.query()!
        if !genericTagTitleArray.isEmpty {
            genericTagQuery.whereKey("genericTags", containsAllObjectsInArray:genericTagTitleArray)
        }
        let finalQuery = querySpecialtyTags(specialtyTagDictionary, query: genericTagQuery)
        finalQuery.whereKey("createdBy", notEqualTo: User.currentUser()!)
        finalQuery.includeKey("createdBy")
        finalQuery.selectKeys(["createdBy"]) //we really only need to know the users
        finalQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
            if let objects = objects where error == nil {
                if objects.isEmpty {
                    print(objects)
                    SCLAlertView().showInfo("No Users Found", subTitle: "No user has those tags")
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
    
    func querySpecialtyTags(specialtyTagDictionary: [SpecialtyCategoryTitles : TagView?], query: PFQuery) -> PFQuery {
        for (specialtyCategoryTitle, tagView) in specialtyTagDictionary {
            if let tagViewTitle = tagView?.currentTitle {
                //the tagView is not nil and the title exists
                if let tagAttribute = specialtyCategoryTitle.associatedDropDownAttribute {
                    switch tagAttribute {
                    case .TagChoices:
                        //does a query on the correct column name and also the SpecialtyTagTitle rawValue, which is an int
                        query.whereKey(specialtyCategoryTitle.parseColumnName, equalTo: tagViewTitle)
                    case .SingleSlider:
                        if let value = getSingleSliderValue(tagViewTitle) {
                            query.whereKey("location", nearGeoPoint: User.currentUser()!.location, withinMiles: value)
                        }
                    case .RangeSlider:
                        let maxAndMinTuple = getRangeSliderValue(tagViewTitle)
                        //For calculating age, just think anyone born 18 years ago from today would be the youngest type of 18 year old their could be. So to do age range, just do this date minus 18 years
                        let minAge : NSDate = maxAndMinTuple.minValue.years.ago
                        let maxAge : NSDate = maxAndMinTuple.maxValue.years.ago
                        query.whereKey("birthDate", lessThanOrEqualTo: minAge) //the younger you are, the higher value your birthdate is. So (April 4th, 1996 > April,6th 1990) when comparing
                        query.whereKey("birthDate", greaterThanOrEqualTo: maxAge)
                    }
                }
            }
        }
        //return the same query after we have added the specialty criteria
        return query
    }
    
    
    //Purpose: just pull out the integers in a substring for the single sliders (instead of "50 mi", we just want 50)
    func getSingleSliderValue(string: String) -> Double? {
        let spaceString : Character = " "
        if let index = string.characters.indexOf(spaceString) {
            let substring = string.substringToIndex(index)
            if let value = Double(substring) {
                return value
            }
        }
        return nil
    }
    
    func getRangeSliderValue(string: String) -> (minValue: Int, maxValue: Int) {
        let spaceString : Character = "-"
        if let index = string.characters.indexOf(spaceString) {
            //the trimming function removes all leading and trailing spaces, so it gets rid of the spaces in " - "
            let minValueSubstring = string.substringToIndex(index).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let maxValueSubstring = string.substringFromIndex(index.advancedBy(1)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) //FromSubstring includes the index, so add 1
            if let minValue = Int(minValueSubstring) {
                if let maxValue = Int(maxValueSubstring) {
                    return (minValue, maxValue)
                }
            }
        }
        return (0,0) //shouldn't reach this point
    }
}

extension SearchTagsViewController : FilterQueryDataStoreDelegate {
    //TODO: for some reason, it would not let me call this setSearchDataArray, only get. Would like to change name to make it better.
    func getSearchDataArray(searchDataArray: [String]) {
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
