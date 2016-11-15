//
//  CardSendMessageDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/14/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class CardSendMessageDataStore {
    //TODO: to get to this point I would have already pulled down a parseSwipe for that user, so should jsut be using those, instead of querying the database for it. 
    func sendCardMessage(text: String, otherUser: User) {
        
        let currentUserIsUserOneQuery = ParseSwipe.query()!
        currentUserIsUserOneQuery.whereKey("userOne", equalTo: User.current()!)
        currentUserIsUserOneQuery.whereKey("userTwo", equalTo: otherUser)
        
        let currentUserIsUserTwoQuery = ParseSwipe.query()!
        currentUserIsUserTwoQuery.whereKey("userOne", equalTo: otherUser)
        currentUserIsUserTwoQuery.whereKey("userTwo", equalTo: User.current()!)
        
        let orQuery = PFQuery.orQuery(withSubqueries: [currentUserIsUserTwoQuery, currentUserIsUserOneQuery])
        orQuery.getFirstObjectInBackground { (object, error) in
            if let parseSwipe = object as? ParseSwipe {
                parseSwipe.currentUserMessage = text
                parseSwipe.saveInBackground()
            } else if let error = error {
                let errorCode = error._code
                if errorCode == PFErrorCode.errorObjectNotFound.rawValue {
                    self.saveNewParseSwipe(messageText: text, otherUser: otherUser)
                } else {
                    print(error)
                }
            }
        }
    
    }
    
    fileprivate func saveNewParseSwipe(messageText: String, otherUser: User) {
        let parseSwipe = ParseSwipe(otherUser: otherUser, currentUserApproval: false)
        parseSwipe.currentUserMessage = messageText
        parseSwipe.saveInBackground()
    }
}
