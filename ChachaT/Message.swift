//
//  Message.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class Message {
    var sender: User
    var dateSent: NSDate
    var body: String
    var hasBeenRead: Bool
    
    init(sender: User, body: String, hasBeenRead: Bool, dateSent: NSDate) {
        self.sender = sender
        self.dateSent = dateSent
        self.body = body
        self.hasBeenRead = hasBeenRead
    }
}