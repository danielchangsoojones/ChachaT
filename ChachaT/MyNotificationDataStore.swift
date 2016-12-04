//
//  MyNotificationDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/4/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

protocol MyNotificationDataStoreDelegate {
    func segueToChat(connection: Connection)
}

class MyNotificationDataStore {
    var delegate: MyNotificationDataStoreDelegate?
    
    init(delegate: MyNotificationDataStoreDelegate) {
        self.delegate = delegate
    }
    
    func findNewMatchFromParseSwipe(objectId: String) {
        let query = ParseSwipe.query()! as! PFQuery<ParseSwipe>
        query.whereKey("objectId", equalTo: objectId)
        query.includeKey("userOne")
        query.includeKey("userTwo")
        query.getFirstObjectInBackground { (parseSwipe, error) in
            if let parseSwipe = parseSwipe {
                let connection = Connection(targetUser: parseSwipe.otherUser, beginningMessage: parseSwipe.otherUserMessage)
                self.delegate?.segueToChat(connection: connection)
            } else if let error = error {
                print(error)
            }
        }
    }
}
