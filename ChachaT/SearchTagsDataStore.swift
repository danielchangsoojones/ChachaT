//
//  SearchTagsDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse
import SCLAlertView

class SearchTagsDataStore {
    var searchDataArray : [Tag] = [] //tags that will be available for searching
    var tagChoicesDataArray : [Tag] = [] //tags that get added to the choices tag view
    
    var delegate: SearchTagsDataStoreDelegate?
    
    init(delegate: SearchTagsDataStoreDelegate) {
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
        query!.findObjectsInBackground { (objects, error) -> Void in
            if let tags = objects as? [Tags] {
                for tag in tags {
                    for tagTitle in tag.genericTags {
                        if !alreadyContainsTagArray.contains(tagTitle) {
                            //our string array does not already contain the tag title, so we can add it to our searchable array
                            alreadyContainsTagArray.append(tagTitle)
                            let tag = Tag(title: tagTitle, attribute: .generic)
                            self.searchDataArray.append(tag)
                        }
                    }
                    self.delegate?.setSearchDataArray(self.searchDataArray)
                }
            }
        }
    }
    
    //Purpose: we only want to pull down generic tags from database to search. The special tags are added on our frontend side.
    func addSpecialtyTagsToSearchDataArray() {
        for specialtyTagTitle in SpecialtyTagTitles.allValues {
            let tag = Tag(title: specialtyTagTitle.toString, attribute: .generic)
            searchDataArray.append(tag)
        }
    }
    
    //Purpose: I want when you first come onto search page, that you see a group of tags already there that you can instantly press
    //I want mostly special tags like "Age Range", "Location", ect. to be there.
    func setSpecialtyTagsIntoDefaultView() {
        for specialtyCategory in SpecialtyCategoryTitles.allCategories {
            if let dropDownAttribute = specialtyCategory.associatedDropDownAttribute {
                switch dropDownAttribute {
                case .tagChoices:
                    let innerTagTitles : [String] = specialtyCategory.specialtyTagTitles.map{
                        $0.toString
                    }
                    let dropDownTag = DropDownTag(specialtyCategory: specialtyCategory.rawValue, innerTagTitles: innerTagTitles, dropDownAttribute: dropDownAttribute)
                    tagChoicesDataArray.append(dropDownTag)
                case .singleSlider, .rangeSlider:
                    let minValue = specialtyCategory.sliderComponents?.min
                    let maxValue = specialtyCategory.sliderComponents?.max
                    let suffix = specialtyCategory.sliderComponents?.suffix
                    var dropDownTag: DropDownTag!
                    if dropDownAttribute == .singleSlider {
                        dropDownTag = DropDownTag(specialtyCategory: specialtyCategory.rawValue, maxValue: maxValue!, suffix: suffix!, dropDownAttribute: dropDownAttribute)
                    } else if dropDownAttribute == .rangeSlider {
                        dropDownTag = DropDownTag(specialtyCategory: specialtyCategory.rawValue, minValue: minValue!, maxValue: maxValue!, suffix: suffix!, dropDownAttribute: dropDownAttribute)
                    }
                    tagChoicesDataArray.append(dropDownTag)
                }
            }
        }
        delegate?.setChoicesViewTagsArray(tagChoicesDataArray)
    }
    
    func findUserArray(_ genericTagTitleArray: [String], specialtyTagDictionary: [SpecialtyCategoryTitles : TagView?]) {
        let genericTagQuery = Tags.query()!
        if !genericTagTitleArray.isEmpty {
            genericTagQuery.whereKey("genericTags", containsAllObjectsIn:genericTagTitleArray)
        }
        let finalQuery = querySpecialtyTags(specialtyTagDictionary, query: genericTagQuery)
        finalQuery.whereKey("createdBy", notEqualTo: User.current()!)
        finalQuery.includeKey("createdBy")
        finalQuery.selectKeys(["createdBy"]) //we really only need to know the users
        finalQuery.findObjectsInBackground(block: { (objects, error) in
            if let objects = objects , error == nil {
                if objects.isEmpty {
                    print(objects)
                    _ = SCLAlertView().showInfo("No Users Found", subTitle: "No user has those tags")
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
    
    func querySpecialtyTags(_ specialtyTagDictionary: [SpecialtyCategoryTitles : TagView?], query: PFQuery<PFObject>) -> PFQuery<PFObject> {
        for (specialtyCategoryTitle, tagView) in specialtyTagDictionary {
            if let tagViewTitle = tagView?.currentTitle {
                //the tagView is not nil and the title exists
                if let tagAttribute = specialtyCategoryTitle.associatedDropDownAttribute {
                    switch tagAttribute {
                    case .tagChoices:
                        //does a query on the correct column name and also the SpecialtyTagTitle rawValue, which is an int.
                        //For example: the query would end up being something like this query.whereKey("sexuality, equalTo: 401)
                        let titleRawValue: Int = SpecialtyTagTitles.stringRawValue(tagViewTitle)!.rawValue
                        query.whereKey(specialtyCategoryTitle.parseColumnName, equalTo: titleRawValue)
                    case .singleSlider:
                        if let value = getSingleSliderValue(tagViewTitle) {
                            query.whereKey("location", nearGeoPoint: User.current()!.location, withinMiles: value)
                        }
                    case .rangeSlider:
                        let maxAndMinTuple = getRangeSliderValue(tagViewTitle)
                        //For calculating age, just think anyone born 18 years ago from today would be the youngest type of 18 year old their could be. So to do age range, just do this date minus 18 years
                        let minAge : Date = maxAndMinTuple.minValue.years.ago
                        let maxAge : Date = maxAndMinTuple.maxValue.years.ago
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
    func getSingleSliderValue(_ string: String) -> Double? {
        let spaceString : Character = " "
        if let index = string.characters.index(of: spaceString) {
            let substring = string.substring(to: index)
            if let value = Double(substring) {
                return value
            }
        }
        return nil
    }
    
    func getRangeSliderValue(_ string: String) -> (minValue: Int, maxValue: Int) {
        let spaceString : Character = "-"
        if let index = string.characters.index(of: spaceString) {
            //the trimming function removes all leading and trailing spaces, so it gets rid of the spaces in " - "
            let minValueSubstring = string.substring(to: index).trimmingCharacters(in: CharacterSet.whitespaces)
            let maxValueSubstring = string.substring(from: string.index(index, offsetBy: 1)).trimmingCharacters(in: CharacterSet.whitespaces) //FromSubstring includes the index, so add 1
            if let minValue = Int(minValueSubstring) {
                if let maxValue = Int(maxValueSubstring) {
                    return (minValue, maxValue)
                }
            }
        }
        return (0,0) //shouldn't reach this point
    }
}

protocol SearchTagsDataStoreDelegate : TagDataStoreDelegate {
    func passUserArrayToMainPage(_ userArray: [User])
}

extension SearchTagsViewController : SearchTagsDataStoreDelegate {
    func passUserArrayToMainPage(_ userArray: [User]) {
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: userArray as AnyObject?) //passing userArray to the segue
    }
}
