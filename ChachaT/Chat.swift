//
//  DateChat.swift
//  ElevenDates
//
//  Created by Brett Keck on 9/18/15.
//  Copyright © 2015 Brett Keck. All rights reserved.
//

import UIKit
import Parse

class Chat: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "Chat"
    }
    
    @NSManaged var chatRoom : String
    @NSManaged var sender : User
    @NSManaged var chatText : String
}
