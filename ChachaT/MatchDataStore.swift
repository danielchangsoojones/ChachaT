//
//  DataStore.swift
//  ElevenDates
//
//  Created by Brett Keck on 9/16/15.
//  Copyright © 2015 Brett Keck. All rights reserved.
//

import UIKit
import SCLAlertView

protocol MatchDataStoreDelegate {
    func passMatchedUsers(matchedUsers: [User])
    func passChats(chats: [Chat])
}

class MatchDataStore: NSObject {
    var delegate: MatchDataStoreDelegate?
    let currentUser = User.currentUser()!
    
    override init() {
        super.init()
    }
    
    init(delegate: MatchDataStoreDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    func findMatchedUsers() {
        var matchedUsers : [User] = []
        let query = Match.query()!
        query.whereKey(Constants.currentUser, equalTo: User.currentUser()!)
        query.whereKey(Constants.mutualMatch, equalTo: true)
        query.includeKey(Constants.targetUser)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let matches = objects as? [Match] where error == nil {
                for match in matches {
                    matchedUsers.append(match.targetUser)
                }
                self.delegate?.passMatchedUsers(matchedUsers)
            } else {
                print(error)
            }
        }
    }
    
    //TODO: figure out which chats have not been read yet, and how to group chats of the same name to the same message cell, as in we don't need two cells for a message sent from the same person.
    //TODO: get the count number for each message cell
    //
    //Purpose: This finds the chat rooms for the currentUser. It only gets the first message of a chat room, and then passes that newest chat to the view controller. We only want one cell per chat room, so even if two users have 50 messages together, we don't want 50 cells. Just one cell with the newest message.
    func findChatRooms() {
        var chatsArray : [Chat] = []
        var chatRooms : [String] = []
        let query = Chat.query()!
        query.includeKey("sender")
        query.whereKey("chatRoom", containsString: currentUser.objectId!)
        query.addDescendingOrder("createdAt") //we want the newest message for the preview message
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let chats = objects as? [Chat] where error == nil {
                for chat in chats {
                    if !chatRooms.contains(chat.chatRoom) {
                        chatRooms.append(chat.chatRoom)
                        chatsArray.append(chat)
                    }
                }
            } else {
                print("error")
            }
            self.delegate?.passChats(chatsArray)
        }
    }
}









