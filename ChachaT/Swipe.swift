//
//  Swipe.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class Swipe {
    var isMatch: Bool = false
    var isNewMatch: Bool = false
    var otherUserApproval: Bool = false
    var currentUserApproval: Bool = false
    var incomingMessage: String?
    var outgoingMessage: String?
    var otherUser: User
    
    //the swipe's correlated server data model
    var parseSwipe: ParseSwipe? = nil
    
    init(parseSwipe: ParseSwipe) {
        self.parseSwipe = parseSwipe
        self.otherUser = parseSwipe.otherUser
        self.otherUserApproval = parseSwipe.otherUserApproval
    }
    
    init(otherUser: User) {
        self.otherUser = otherUser
    }
    
    init(otherUser: User, otherUserApproval: Bool, parseSwipe: ParseSwipe) {
        self.otherUser = otherUser
        self.otherUserApproval = otherUserApproval
        self.parseSwipe = parseSwipe
    }
    
    func approve() {
        let previousCurrentUserApproval = currentUserApproval
        currentUserApproval = true
        isMatch = currentUserApproval && otherUserApproval
        isNewMatch = !previousCurrentUserApproval && isMatch
    }
    
    func nope() {
        currentUserApproval = false
        isMatch = false
    }
}
