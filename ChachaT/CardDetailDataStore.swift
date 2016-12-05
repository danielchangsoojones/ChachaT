//
//  CardDetailDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

protocol CardDetailDataStoreDelegate {
    func passTags(tagArray: [Tag])
}

class CardDetailDataStore {
    var delegate: CardDetailDataStoreDelegate?
    var searchedParseTags: [ParseTag] = []
    
    init(delegate: CardDetailDataStoreDelegate) {
        self.delegate = delegate
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

//loading tags extension
extension CardDetailDataStore {
    func loadTags(user: User) {
        let approvedTagQuery = createCommonQuery(user: user)
        approvedTagQuery.whereKey("approved", notEqualTo: false)
        
        //get any tags created by the current user, and we will show them as pending even if the other user has not approved it yet.
        let pendingTagQuery = createCommonQuery(user: user)
        pendingTagQuery.whereKey("createdBy", equalTo: User.current()!)
        
        let orQuery = PFQuery.orQuery(withSubqueries: [approvedTagQuery, pendingTagQuery])
        orQuery.findObjectsInBackground { (objects, error) in
            if let parseUserTags = objects as? [ParseUserTag] {
                let tags: [Tag] = parseUserTags.map({ (parseUserTag: ParseUserTag) -> Tag in
                    let tag = Tag(title: parseUserTag.lowercasedTagTitle, attribute: .generic)
                    tag.isPending = parseUserTag.isPending
                    return tag
                })
                let sortedTags = tags.sorted(by: { (previousTag: Tag, nextTag: Tag) -> Bool in
                    return previousTag.title.localizedCaseInsensitiveCompare(nextTag.title) == ComparisonResult.orderedAscending
                })
                self.delegate?.passTags(tagArray: sortedTags)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    private func createCommonQuery(user: User) -> PFQuery<PFObject> {
        let query = ParseUserTag.query()!
        query.whereKey("user", equalTo: user)
        return query
    }
}
