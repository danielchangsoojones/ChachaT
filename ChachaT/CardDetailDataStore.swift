//
//  CardDetailDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CardDetailDataStore {
    var delegate: CardDetailDataStoreDelegate?
    
    init(delegate: CardDetailDataStoreDelegate) {
        self.delegate = delegate
    }
    
    func loadTags(user: User) {
        let query = Tags.query()!
        query.whereKey("createdBy", equalTo: user)
        query.findObjectsInBackground { (objects, error) in
            if let tags = objects as? [Tags] {
                for parseTag in tags {
                    var tagArray: [Tag] = []
                    for tagTitle in parseTag.genericTags {
                        let tag = Tag(title: tagTitle, attribute: .generic)
                        tagArray.append(tag)
                    }
                    self.delegate?.passTags(tagArray: tagArray)
                }
            } else if error != nil {
                print(error)
            }
        }
    }
}

protocol CardDetailDataStoreDelegate {
    func passTags(tagArray: [Tag])
}

extension CardDetailViewController: CardDetailDataStoreDelegate {
    func passTags(tagArray: [Tag]) {
        for tag in tagArray {
            _ = self.theCardUserTagListView.addTag(tag.title)
        }
    }
}
