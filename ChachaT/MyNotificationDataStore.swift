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
    
    func findUser(objectId: String) {
        let query = User.query()! as! PFQuery<User>
        query.whereKey("objectId", equalTo: objectId)
        query.getFirstObjectInBackground { (user, error) in
            if let user = user {
                let connection = Connection(targetUser: user)
                self.delegate?.segueToChat(connection: connection)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func resetNotificationBadgeCount() {
        let currentInstallation = PFInstallation.current()
        if currentInstallation?.badge != 0 {
            currentInstallation?.badge = 0
            currentInstallation?.saveEventually()
        }
    }
    
    func setDeviceTokenToPoint(deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.channels = ["global"]
        installation?.saveInBackground()
    }
}
