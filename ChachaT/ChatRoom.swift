//
//  ChatRoom.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class ChatRoom: NSObject {
    var users: [User]
    var name: String = ""
    var mainImage: AnyObject!
    var messages: [Message]
    
    init(users: [User], name: String = "", messages: [Message], mainImage: AnyObject? = nil) {
        self.users = users
        self.messages = messages
        super.init()
        let chatAttributes = setChatAttributes(users, name: name, mainImage: mainImage)
        self.name = chatAttributes.name
        self.mainImage = chatAttributes.mainImage
    }
    
    func setChatAttributes(_ users: [User], name: String, mainImage: AnyObject?) -> (name: String, mainImage: AnyObject) {
        if let otherUser = getOtherUser() {
            //this is a one-on-one chat
            if let fullName = otherUser.fullName, let profileImage = otherUser.profileImage {
                return (fullName,profileImage)
            }
        }
        //this is a group chat
        return (name, mainImage ?? "" as AnyObject)
    }
    
    func getOtherUser() -> User? {
        if users.count == 2{
            //this is a one-on-one chat
            for user in users where user != User.current() {
                return user
            }
        }
        return nil //this is a group chat
    }
}
