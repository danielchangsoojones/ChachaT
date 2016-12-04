//
//  Connection.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

//TODO: I would like to call this class a Match, but right now, the Match class holds the Parse datamodel
class Connection {
    var targetUser: User //the user who the currentUser got matched with
    var hasSeen: Bool = false //the currentUser has or has not checked the match out already. Checking them out, means tapping on the Match to start a conversation.
    var beginningMessage: String? = nil
    
    init(targetUser: User, hasSeen: Bool = false, beginningMessage: String? = nil) {
        self.targetUser = targetUser
        self.hasSeen = hasSeen
        self.beginningMessage = beginningMessage
    }
}
