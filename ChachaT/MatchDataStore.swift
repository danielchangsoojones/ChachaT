//
//  DataStore.swift
//  ElevenDates
//
//  Created by Brett Keck on 9/16/15.
//  Copyright © 2015 Brett Keck. All rights reserved.
//

import UIKit

class MatchDataStore: NSObject {
    var delegate: MatchDataStoreDelegate?
    let currentUser = User.current()!
    
    override init() {
        super.init()
    }
    
    init(delegate: MatchDataStoreDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    func findMatchedUsers() {
        var connections : [Connection] = []
        let query = Match.query()!
        query.whereKey(Constants.currentUser, equalTo: User.current()!)
        query.whereKey(Constants.mutualMatch, equalTo: true)
        query.includeKey(Constants.targetUser)
        query.findObjectsInBackground { (objects, error) in
            if let matches = objects as? [Match] , error == nil {
                for match in matches {
                    let connection = Connection(targetUser: match.targetUser)
                    connections.append(connection)
                }
                self.delegate?.passMatches(connections)
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
        var chatRooms : [ChatRoom] = []
        var alreadyContainedChats: [String] = []
        let query = Chat.query()!
        query.includeKey("sender")
        query.whereKey("chatRoom", contains: currentUser.objectId!)
        query.addDescendingOrder("createdAt") //we want the newest message for the preview message
        query.findObjectsInBackground { (objects, error) in
            if let chats = objects as? [Chat] , error == nil {
                for chat in chats {
                    if !alreadyContainedChats.contains(chat.chatRoom) {
                        alreadyContainedChats.append(chat.chatRoom)
                        //TODO: make the message have an actual date for the date sent
                        let message = Message(sender: chat.sender, body: chat.chatText, hasBeenRead: chat.readByReceiver, dateSent: Date())
                        let chatRoom = ChatRoom(users: [chat.sender, chat.receiver], messages: [message])
                        chatRooms.append(chatRoom)
                    }
                }
            } else {
                print("error")
            }
            self.delegate?.passChatRooms(chatRooms)
        }
    }
    
    func messagesHaveBeenRead(_ chatRoom: ChatRoom) {
        //TODO: make the chatroom say that all messages have been read
        
    }
}

protocol MatchDataStoreDelegate {
    func passMatches(_ matches: [Connection])
    func passChatRooms(_ rooms: [ChatRoom])
}

extension MatchesViewController: MatchDataStoreDelegate {
    func passMatches(_ matches: [Connection]) {
        self.matches = matches
        theTableView.reloadData()
    }
    
    func passChatRooms(_ rooms: [ChatRoom]) {
        self.chatRooms = rooms
        theTableView.reloadData()
    }
}









