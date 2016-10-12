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
        //TODO: load the users tags
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
