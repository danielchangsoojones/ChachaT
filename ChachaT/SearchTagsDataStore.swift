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
        //TODO: figure out how to do the search array in a reasonable fashion
    }
    
    //Purpose: I want when you first come onto search page, that you see a group of tags already there that you can instantly press
    //I want mostly special tags like "Age Range", "Location", ect. to be there.
    func setSpecialtyTagsIntoDefaultView() {
        let query = DropDownCategory.query()! as! PFQuery<DropDownCategory>
        query.findObjectsInBackground { (categories, error) in
            if let categories = categories {
                for dropDownCategory in categories {
                    var dropDownTag: DropDownTag?
                    switch dropDownCategory.type {
                    case DropDownAttributes.tagChoices.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, innerTagTitles: dropDownCategory.innerTagTitles!, dropDownAttribute: DropDownAttributes.tagChoices)
                    case DropDownAttributes.singleSlider.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, maxValue: dropDownCategory.max, suffix: dropDownCategory.suffix, dropDownAttribute: DropDownAttributes.singleSlider)
                    case DropDownAttributes.rangeSlider.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, minValue: dropDownCategory.min, maxValue: dropDownCategory.max, suffix: dropDownCategory.suffix, dropDownAttribute: DropDownAttributes.rangeSlider)
                    default:
                        break
                    }
                    if let dropDownTag = dropDownTag {
                        self.tagChoicesDataArray.append(dropDownTag)
                    }
                }
                self.delegate?.setChoicesViewTagsArray(self.tagChoicesDataArray)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func findUserArray(chosenTags: [Tag]) {
        var query = User.query()!
        var tagTitleArray: [String] = []
        for tag in chosenTags {
            if let dropDownTag = tag as? DropDownTag {
                query = addSliderQueryComponents(dropDownTag: dropDownTag, query: query)
            } else {
                tagTitleArray.append(tag.title)
            }
        }
        if !tagTitleArray.isEmpty {
            //query any tags with the title
            let innerQuery = ParseTag.query()!
            innerQuery.whereKey("title", containedIn: ["flounder"])
            query.whereKey("tags", matchesQuery: innerQuery)
        }

        query.findObjectsInBackground { (objects, error) in
            if let users = objects as? [User] {
                if users.isEmpty {
                    _ = SCLAlertView().showInfo("No Users Found", subTitle: "No user has those tags")
                } else {
                    self.delegate?.passUserArrayToMainPage(users)
                }
            } else if error != nil {
                print(error)
            }
        }
    }
    
    func addSliderQueryComponents(dropDownTag: DropDownTag, query: PFQuery<PFObject>) -> PFQuery<PFObject> {
        switch dropDownTag.specialtyCategory {
            //TODO: these cases should be based upon the parse column name
        case "Distance":
            query.whereKey("location", nearGeoPoint: User.current()!.location, withinMiles: Double(dropDownTag.maxValue))
        case "Age Range":
            //For calculating age, just think anyone born 18 years ago from today would be the youngest type of 18 year old their could be. So to do age range, just do this date minus 18 years
            let minAge : Date = dropDownTag.minValue.years.ago
            let maxAge : Date = dropDownTag.maxValue.years.ago
            query.whereKey("birthDate", lessThanOrEqualTo: minAge) //the younger you are, the higher value your birthdate is. So (April 4th, 1996 > April,6th 1990) when comparing
            query.whereKey("birthDate", greaterThanOrEqualTo: maxAge)
        default:
            break
        }
        return query
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
