//
//  ChatDataNegotiator.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/22/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Parse
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ChatDataNegotiator {
    
    var isLoading = false
    var chatRoomName = ""
    
    fileprivate var delegate: ChatDataNegotiatorDelegate?
    
    init(delegate: ChatDataNegotiatorDelegate) {
        self.delegate = delegate
    }
    
    func getsenderID() -> String {
        return User.current()!.objectId!
    }
    
    func getSenderDisplayName() -> String {
        return User.current()!.fullName!
    }
    
    func getChatRoomName(_ otherUser: User) -> String {
        let currentUser = User.current()!
        // We create a chatroom for each user pair. it needs to be the same for both
        // so we always put smaller user id first
        let name = currentUser.objectId > otherUser.objectId ?
            "\(currentUser.objectId)-\(otherUser.objectId)" :
            "\(otherUser.objectId)-\(currentUser.objectId)"
        return name
    }
    
    func loadMessages(_ messages: [JSQMessage]) {
        if !isLoading {
            var messagesCopy : [JSQMessage] = messages
            isLoading = true
            let message_last = messagesCopy.last
            
            // query to fetch messages
            let query = Chat.query()!
            query.whereKey(Constants.chatRoom, equalTo: chatRoomName)
            // time based pagination
            if message_last != nil {
                query.whereKey(Constants.createdAt, greaterThan: message_last!.date)
            }
            // we need this so we can get the sender's objectId for simplicity
            query.includeKey(Constants.sender)
            // show messages in order sent
            query.order(byAscending: Constants.createdAt)
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    for object in objects! {
                        // Go through each Chat message and create a
                        // JSQMessage for display on this screen
                        let chat = object as! Chat
                        let message = JSQMessage(senderId: chat.sender.objectId, senderDisplayName: chat.sender.fullName, date: chat.createdAt, text: chat.chatText)
                        
                        messagesCopy.append(message!)
                        
                        // just ensure we cache the user object for later
                        self.delegate?.cacheUserObject(chat.sender, objectID: chat.sender.objectId!)
                    }
                    self.delegate?.passMessages(messagesCopy)
                    if !objects!.isEmpty {
                        self.delegate?.finishReceivingMessage()
                    }
                }
                self.isLoading = false
            })
            
        }
    }
    
    func sendMessage(_ text: String, otherUser: User) {
        // When they hit send. Save their message.
        let chat = Chat()
        chat.chatRoom = self.chatRoomName
        chat.sender = User.current()!
        chat.receiver = otherUser
        chat.chatText = text
        chat.readByReceiver = false
        
        chat.saveInBackground { (succeeded, error) in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.delegate?.loadMessages()
            }
        }
        self.delegate?.finishSendingMessage()
    }

}

protocol ChatDataNegotiatorDelegate {
    func finishReceivingMessage()
    func finishSendingMessage()
    func passMessages(_ messages: [JSQMessage])
    func cacheUserObject(_ user: User, objectID: String)
    func loadMessages()
    func loadAvatarImage(_ data: Data)
}

extension ChatViewController: ChatDataNegotiatorDelegate {
    func finishMessages() {
        self.finishReceivingMessage()
    }
    
    func passMessages(_ messages: [JSQMessage]) {
        self.messages = messages
    }
    
    func cacheUserObject(_ user: User, objectID: String) {
        self.users[objectID] = user
    }
    
    func loadAvatarImage(_ data: Data) {
        
    }
}
