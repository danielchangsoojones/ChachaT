//
//  SuperTagDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class SuperTagDataStore: SuperParseSwipeDataStore {
    
    var superTagDelegate: TagDataStoreDelegate?
    var searchTags: [ParseTag] = []
    fileprivate var isSearching: Bool = false
    
    init(superTagDelegate: TagDataStoreDelegate) {
        self.superTagDelegate = superTagDelegate
    }
    
    func searchForTags(searchText: String) {
        if !isSearching {
            isSearching = true
            let query = ParseTag.query()! as! PFQuery<ParseTag>
            query.whereKey("title", contains: searchText.lowercased())
            query.findObjectsInBackground { (parseTags, error) in
                var searchDataArray: [Tag] = []
                if let parseTags = parseTags {
                    self.searchTags = parseTags
                    let newSearchResults: [Tag] = parseTags.map({ (parseTag: ParseTag) -> Tag in
                        let tag = Tag(title: parseTag.tagTitle, attribute: TagAttributes.generic)
                        return tag
                    })
                    searchDataArray.append(contentsOf: newSearchResults)
                } else if let error = error {
                    print(error)
                }
                self.compareToNewestSearch(queriedSearchText: searchText)
                self.superTagDelegate?.passSearchResults(searchTags: searchDataArray)
            }
        }
    }
    
    fileprivate func compareToNewestSearch(queriedSearchText: String) {
        if let newestSearchText = superTagDelegate?.getMostCurrentSearchText(), queriedSearchText != newestSearchText {
            searchForTags(searchText: newestSearchText)
        }
        self.isSearching = false
    }
}



protocol TagDataStoreDelegate {
    func setChoicesViewTagsArray(_ tagChoicesDataArray: [Tag])
    func passSearchResults(searchTags: [Tag]) //implemented in the main class SuperTagViewController, not in the extension because we need to override it in subclasses. And, currently, you can only override superclass methods that are not located in an extension. In future versions of swift, this should change. 
    func getMostCurrentSearchText() -> String
}

extension SuperTagViewController : TagDataStoreDelegate {
    func setChoicesViewTagsArray(_ tagChoicesDataArray: [Tag]) {
        self.tagChoicesDataArray = tagChoicesDataArray
        loadChoicesViewTags()
    }
}
