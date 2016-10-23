//
//  ChatDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/22/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Parse

class ChatDataStore {
    
    var isLoading = false
    var chatRoomName = ""
    var otherUser: User!
    
    fileprivate var delegate: ChatDataStoreDelegate?
    
    init(chatUsers: [User], delegate: ChatDataStoreDelegate) {
        for user in chatUsers where user != User.current() {
            //there should just be one other user who is not the current user. When group chats get implemented, this code will break.
            self.otherUser = user
            chatRoomName = getChatRoomName(user)
        }
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
        // so we always put smaller (as in alphabetically) user id first
        let name = currentUser.objectId! < otherUser.objectId! ?
            "\(currentUser.objectId!)-\(otherUser.objectId!)" :
            "\(otherUser.objectId!)-\(currentUser.objectId!)"
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
                        let user = chat.sender
                        
                        var message: JSQMessage!
                        if let chatPicture = chat.picture {
                            let mediaItem = JSQPhotoMediaItem(image: nil)
                            //TODO: as a parameter, I need to take in the senderID so I can compare these
                            mediaItem?.appliesMediaViewMaskAsOutgoing = user.objectId! == User.current()!.objectId!
                            message = JSQMessage(senderId: user.objectId!, senderDisplayName: user.fullName ?? "", date: chat.createdAt, media: mediaItem)
                            
                            chatPicture.getDataInBackground(block: { (imageData, error) -> Void in
                                if error == nil {
                                    mediaItem?.image = UIImage(data: imageData!)
                                    self.delegate?.reloadCollectionView()
                                }
                            })
                        }else{
                            message = JSQMessage(senderId: user.objectId!, senderDisplayName: user.fullName ?? "", date: chat.createdAt, text: chat.chatText)
                        }
                        
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
        let chat = createChat(chatText: text)
        
        chat.saveInBackground { (succeeded, error) in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.delegate?.loadMessages()
            }
        }
        self.delegate?.finishSendingMessage()
    }
    
    func sendMessage(text: String, pictureFile: PFFile!) {
        let chat = createChat(chatText: text)
        if let pictureFile = pictureFile {
            chat.chatText = "[Picture message]"
            chat.picture = pictureFile
        }

        chat.saveInBackground { (succeeded, error) -> Void in
            if succeeded {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.addMessage(chat: chat)
                self.delegate?.finishSendingMessage()
            }else{
                print(error)
            }
        }
    }
    
    fileprivate func createChat(chatText: String) -> Chat {
        let chat = Chat()
        chat.chatRoom = self.chatRoomName
        chat.sender = User.current()!
        chat.receiver = self.otherUser
        chat.chatText = chatText
        chat.readByReceiver = false
        return chat
    }
    
    func addMessage(chat: Chat) {
        var message: JSQMessage!
        
        let user = chat.sender
        
        if let chatPicture = chat.picture {
            
            let mediaItem = JSQPhotoMediaItem(image: nil)
            //TODO: as a parameter, I need to take in the senderID so I can compare these
//            mediaItem?.appliesMediaViewMaskAsOutgoing = (user.objectId == self.getsenderID)
            mediaItem?.appliesMediaViewMaskAsOutgoing = true
            message = JSQMessage(senderId: user.objectId, senderDisplayName: user.fullName, date: chat.createdAt, media: mediaItem)
            
            chatPicture.getDataInBackground(block: { (imageData, error) -> Void in
                if error == nil {
                    mediaItem?.image = UIImage(data: imageData!)
                    self.delegate?.reloadCollectionView()
                }
            })
        }else{
            message = JSQMessage(senderId: user.objectId, senderDisplayName: user.fullName, date: chat.createdAt, text: chat.chatText)
        }
        delegate?.appendMessage(message: message)
    }

}

protocol ChatDataStoreDelegate {
    func finishReceivingMessage()
    func finishSendingMessage()
    func passMessages(_ messages: [JSQMessage])
    func cacheUserObject(_ user: User, objectID: String)
    func loadMessages()
    func loadAvatarImage(_ data: Data)
    func reloadCollectionView()
    func appendMessage(message: JSQMessage)
}

extension ChatViewController: ChatDataStoreDelegate {
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
    
    func reloadCollectionView() {
        self.collectionView.reloadData()
    }
    
    func appendMessage(message: JSQMessage) {
        self.messages.append(message)
    }
}
