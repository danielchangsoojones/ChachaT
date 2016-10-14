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
        setSpecialtyTagsIntoDefaultView()
    }
    
    //Purpose: I want when you first come onto search page, that you see a group of tags already there that you can instantly press
    //I want mostly special tags like "Age Range", "Location", ect. to be there.
    func setSpecialtyTagsIntoDefaultView() {
        let query = DropDownCategory.query()! as! PFQuery<DropDownCategory>
        query.includeKey("innerTags")
        query.findObjectsInBackground { (categories, error) in
            if let categories = categories {
                for dropDownCategory in categories {
                    var dropDownTag: DropDownTag?
                    switch dropDownCategory.type {
                    case DropDownAttributes.tagChoices.rawValue:
                        dropDownTag = DropDownTag(specialtyCategory: dropDownCategory.name, innerTagTitles: dropDownCategory.innerTagTitles, dropDownAttribute: DropDownAttributes.tagChoices)
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
        let tuple = createFindUserQuery(chosenTags: chosenTags)

        tuple.query.findObjectsInBackground { (objects, error) in
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

//MARK: for searching
extension SearchTagsDataStore {
    func searchForTags(searchText: String) {
        let query = ParseTag.query()! as! PFQuery<ParseTag>
        query.whereKey("title", contains: searchText.lowercased())
        query.findObjectsInBackground { (parseTags, error) in
            if let parseTags = parseTags {
                //TODO: what if the user is typing super fast. We don't want to be constantly trying to catch their last letter, just the newest letter after we have completed a query.
                self.searchDataArray.removeAll()
                let newSearchResults: [Tag] = parseTags.map({ (parseTag: ParseTag) -> Tag in
                    let tag = Tag(title: parseTag.title, attribute: TagAttributes.generic)
                    return tag
                })
                self.searchDataArray.append(contentsOf: newSearchResults)
            } else if let error = error {
                print(error)
            }
            self.delegate?.passSearchResults(searchTags: self.searchDataArray)
        }
    }
    

}

//Mark: After a tag is tapped, show successive tags/find users
extension SearchTagsDataStore {
    func retrieveSuccessiveTags(chosenTags: [Tag]) {
        let tuple = createFindUserQuery(chosenTags: chosenTags)
        
        tuple.query.findObjectsInBackground { (objects, error) in
            if let users = objects as? [User] {
                for user in users {
                    
                    
                    let query = user.tags.query()
                    query.whereKey("title", notEqualTo: tuple.chosenTitleArray)
                    query.findObjectsInBackground(block: { (<#[ParseTag]?#>, <#Error?#>) in
                        <#code#>
                    })
                }
            }
        }
    }
    
    fileprivate func createFindUserQuery(chosenTags: [Tag]) -> (query: PFQuery<PFObject>, chosenTitleArray: [String]) {
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
        return (query, tagTitleArray)
    }
}

protocol SearchTagsDataStoreDelegate : TagDataStoreDelegate {
    func passUserArrayToMainPage(_ userArray: [User])
    func passSearchResults(searchTags: [Tag])
}

extension SearchTagsViewController : SearchTagsDataStoreDelegate {
    func passUserArrayToMainPage(_ userArray: [User]) {
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: userArray as AnyObject?) //passing userArray to the segue
    }
    
    func passSearchResults(searchTags: [Tag]) {
        tagChoicesView.removeAllTags()
        if searchTags.isEmpty {
            //TODO: there were no results from the search
            //TODO: If we can't find any more tags here, then stop querying any farther if the suer keeps typing
        } else {
            for (index, tag) in searchTags.enumerated() {
                let tagView = tagChoicesView.addTag(tag.title)
                if index == 0 {
                    //we want the first TagView in search area to be selected, so then you click search, and it adds to search bar. like 8tracks.
                    tagView.isSelected = true
                }
            }
        }
    }
}
