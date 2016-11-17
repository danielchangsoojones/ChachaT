//
//  SuperParseSwipeDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/15/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class SuperParseSwipeDataStore {
    func convertParseSwipeToSwipe(parseSwipe: ParseSwipe) -> Swipe {
        let otherUser = parseSwipe.otherUser
        let swipe = Swipe(otherUser: otherUser, otherUserApproval: parseSwipe.otherUserApproval, parseSwipe: parseSwipe)
        swipe.incomingMessage = parseSwipe.otherUserMessage
        return swipe
    }
}
