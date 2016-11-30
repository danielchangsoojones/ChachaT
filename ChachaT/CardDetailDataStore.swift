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
        superTagDataStore.searchForTags(searchText: searchText)
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
