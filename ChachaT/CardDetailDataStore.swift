//
//  CardDetailDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class CardDetailDataStore {
    var delegate: CardDetailDataStoreDelegate?
    var searchedParseTags: [ParseTag] = []
    
    init(delegate: CardDetailDataStoreDelegate) {
        self.delegate = delegate
    }
    
    func loadTags(user: User) {
        let query = user.tags.query() 
        query.findObjectsInBackground { (parseTags, error) in
            if let parseTags = parseTags {
                let tags: [Tag] = parseTags.map({ (parseTag: ParseTag) -> Tag in
                    return Tag(title: parseTag.tagTitle, attribute: .generic)
                })
                self.delegate?.passTags(tagArray: tags)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func searchForTags(searchText: String, delegate: TagDataStoreDelegate) {
        let superTagDataStore = SuperTagDataStore(superTagDelegate: delegate)
        
        let query = superTagDataStore.createSearchQuery(searchText: searchText)
        query.whereKeyDoesNotExist("dropDownCategory")
        
        superTagDataStore.runSearchQuery(searchText: searchText, query: query)
        searchedParseTags = superTagDataStore.searchTags
    }
    
    func setSearchedTags(tags: [Tag]) {
        searchedParseTags = tags.filter({ (tag: Tag) -> Bool in
            return tag.parseTag != nil
        }).map({ (tag: Tag) -> ParseTag in
            return tag.parseTag!
        })
    }
    
    func saveTag(title: String, userForTag: User) {
        if let parseTag = ParseTag.findParseTag(title: title, parseTags: searchedParseTags) {
            //the parseTag already exists in database
            saveParseUserTag(parseTag: parseTag, userForTag: userForTag)
        } else {
            //doesn't exist yet
            let parseTag = ParseTag(title: title, attribute: .generic)
            parseTag.saveInBackground(block: { (success, error) in
                if success {
                    self.saveParseUserTag(parseTag: parseTag, userForTag: userForTag)
                } else if let error = error {
                    print(error)
                }
            })
        }
    }
    
    fileprivate func saveParseUserTag(parseTag: ParseTag, userForTag: User) {
        let parseUserTag = ParseUserTag(parseTag: parseTag, user: userForTag, isPending: true, approved: false)
        parseUserTag.saveInBackground()
    }
}

protocol CardDetailDataStoreDelegate {
    func passTags(tagArray: [Tag])
}

extension CardDetailViewController: CardDetailDataStoreDelegate {
    func passTags(tagArray: [Tag]) {
        for tag in tagArray {
            //add the appropriate tags to the tagListView
//            _ = self.theCardUserTagListView.addTag(tag.title)
        }
    }
}
