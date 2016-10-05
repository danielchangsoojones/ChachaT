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
    var otherUserApproval: Bool = false
    var currentUserApproval: Bool = false
    var otherUser: User
    
    init(otherUser: User, otherUserApproval: Bool) {
        self.otherUser = otherUser
        self.otherUserApproval = otherUserApproval
    }
    
    func approve() {
        currentUserApproval = true
        isMatch = currentUserApproval && otherUserApproval
    }
    
    func nope() {
        currentUserApproval = false
        isMatch = false
    }
    
}
