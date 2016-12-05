//
//  DataStore.swift
//  ElevenDates
//
//  Created by Brett Keck on 9/16/15.
//  Copyright © 2015 Brett Keck. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery

class MatchDataStore: NSObject {
    var delegate: MatchDataStoreDelegate?
    let currentUser = User.current()!
    
    var chatRooms : [ChatRoom] = []
    
    //Parse Live Query variables
    fileprivate var subscription: Subscription<Chat>?
    fileprivate var liveQuery: PFQuery<Chat> = Chat.query()! as! PFQuery<Chat>
    var connected: Bool = false
    
    override init() {
        super.init()
    }
    
    init(delegate: MatchDataStoreDelegate) {
        super.init()
        self.delegate = delegate
        subscribeToLiveMessaging()
    }
    
    func findMatchedUsers() {
        let currentUserIsUserOneQuery = createInnerQuery(user: "userOne")
        let currentUserIsUserTwoQuery = createInnerQuery(user: "userTwo")
        
        let orQuery = PFQuery.orQuery(withSubqueries: [currentUserIsUserOneQuery, currentUserIsUserTwoQuery])
        orQuery.includeKey("userOne")
        orQuery.includeKey("userTwo")
        orQuery.cachePolicy = .cacheThenNetwork
        orQuery.findObjectsInBackground { (objects, error) in
            if let parseSwipes = objects as? [ParseSwipe] {
                var connections : [Connection] = []
                for parseSwipe in parseSwipes {
                    let connection = Connection(targetUser: parseSwipe.otherUser)
                    connections.append(connection)
                }
                self.delegate?.passMatches(connections)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func createInnerQuery(user: String) -> PFQuery<PFObject> {
        let query = ParseSwipe.query()!
        query.whereKey(user, equalTo: User.current()!)
        query.whereKey("userOneApproval", equalTo: true)
        query.whereKey("userTwoApproval", equalTo: true)
        return query
    }
    
    //TODO: figure out which chats have not been read yet, and how to group chats of the same name to the same message cell, as in we don't need two cells for a message sent from the same person.
    //TODO: get the count number for each message cell
    //TODO: I don't really need to get all the messages, just the firstObjectInBackground for each particular chat room. Don't know if this is possible...
    //Purpose: This finds the chat rooms for the currentUser. It only gets the first message of a chat room, and then passes that newest chat to the view controller. We only want one cell per chat room, so even if two users have 50 messages together, we don't want 50 cells. Just one cell with the newest message.
    func findChatRooms() {
        var alreadyContainedChats: [String] = []
        let query = Chat.query()!
        query.includeKey("sender")
        query.includeKey("receiver")
        query.whereKey("chatRoom", contains: currentUser.objectId!)
        query.addDescendingOrder("createdAt") //we want the newest message for the preview message
        query.cachePolicy = .cacheThenNetwork
        query.findObjectsInBackground { (objects, error) in
            if let chats = objects as? [Chat] , error == nil {
                for chat in chats {
                    if !alreadyContainedChats.contains(chat.chatRoom) {
                        alreadyContainedChats.append(chat.chatRoom)
                        //TODO: make the message have an actual date for the date sent
                        let message = Message(sender: chat.sender, body: chat.chatText, hasBeenRead: chat.readByReceiver, dateSent: Date())
                        let chatRoom = ChatRoom(users: [chat.sender, chat.receiver], messages: [message])
                        if chatRoom.getOtherUser() != nil {
                            self.chatRooms.append(chatRoom)
                        }
                    }
                }
            } else {
                print("error")
            }
            self.delegate?.passChatRooms(self.chatRooms)
        }
    }
    
    func messagesHaveBeenRead(_ chatRoom: ChatRoom) {
        //TODO: make the chatroom say that all messages have been read
        
    }
}

//Live query extension
extension MatchDataStore {
    fileprivate func subscribeToLiveMessaging() {
        if connected {
            unsubscribeToLiveMessaging()
        }
        
        //in Parse Live Query, you can't query a pointer because of a bug, so we can only query the objectId for now until this gets fixed in the open source community
        //we don't need to pay attention to the sender as CurrentUser because if the user was the sender, they wouldn't be able to send the message from the MatchesViewController
        liveQuery.whereKey("recieverObjectId", equalTo: User.current()!.objectId!)
        
        //The subscription variable has to be held in a global variable, if not, then when the current function finishes running, then it will deallocate the subscription, and the event will NEVER get handled.
        subscription = liveQueryClient.subscribe(liveQuery).handle(Event.created) { (query: PFQuery<Chat>, chat: Chat) in
            self.connected = true
        
                //We have to run the query again because ParseLiveQuery is buggy and doesn't work with pointers, so we basically just are using parseLiveQuery as an alert to tell us to query
            query.includeKey("sender")
            query.whereKey("objectId", equalTo: chat.objectId!)
                
            query.getFirstObjectInBackground(block: { (chat, error) in
                if let chat = chat, !self.doesChatRoomAlreadyExist(chat: chat) {
                    let message = Message(sender: chat.sender, body: chat.chatText, hasBeenRead: chat.readByReceiver, dateSent: chat.createdAt!)
                    let chatRoom = ChatRoom(users: [User.current()!, chat.sender], messages: [message])
                    self.chatRooms.insertAsFirst(chatRoom)
                    self.delegate?.passChatRooms(self.chatRooms)
                } else if let error = error {
                    print(error)
                }
            })
        }
    }
    
    fileprivate func doesChatRoomAlreadyExist(chat: Chat) -> Bool {
        let chatRoom: ChatRoom? = self.chatRooms.first { (chatRoom: ChatRoom) -> Bool in
            //check if any of the chatRooms contain both objectIds, we can't use the chat's user pointers because Parse Live Query is broken
            let chatUsersObjectIds: [String] = [User.current()!.objectId!, chat.sender.objectId!]
            let chatRoomUsersObjectIds: [String] = chatRoom.users.map({ (user: User) -> String in
                return user.objectId!
            })
            return chatRoomUsersObjectIds.containsArray(chatUsersObjectIds)
        }
        
        if let chatRoom = chatRoom {
            let message = Message(sender: chat.sender, body: chat.chatText, hasBeenRead: chat.readByReceiver, dateSent: chat.createdAt!)
            chatRoom.messages.insertAsFirst(message)
            //insert this chat room at the front of the array because it is the newest
            self.chatRooms.removeObject(chatRoom)
            self.chatRooms.insertAsFirst(chatRoom)
            self.delegate?.passChatRooms(self.chatRooms)
        }
        
        return chatRoom != nil
    }
    
    func unsubscribeToLiveMessaging() {
        liveQueryClient.unsubscribe(liveQuery, handler: subscription!)
        connected = false
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









