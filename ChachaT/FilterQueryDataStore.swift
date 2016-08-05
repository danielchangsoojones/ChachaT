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
}

class FilterQueryDataStore {
    var searchDataArray : [Tag] = [] //tags that will be available for searching
    var tagChoicesDataArray : [Tag] = [] //tags that get added to the choices tag view
    var chosenTagArray : [Tag] = [] //tags that get added to chosen tag view
    
    var delegate: FilterQueryDataStoreDelegate?
    
    init() {
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
                for tag in tags where tag.title != nil {
                    //making sure tag title is not nil because we only want to pull down generic tags from database to search. The special tags are added on our frontend side.
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
}

extension FilterQueryViewController : FilterQueryDataStoreDelegate {
    func getSearchDataArray(searchDataArray: [Tag]) {
        self.searchDataArray = searchDataArray
    }
}
