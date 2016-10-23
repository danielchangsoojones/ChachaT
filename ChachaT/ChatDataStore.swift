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
        // just ensure we cache the user object for later
        self.delegate?.cacheUserObject(otherUser, objectID: otherUser.objectId!)
        self.delegate?.cacheUserObject(User.current()!, objectID: User.current()!.objectId!)
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
            isLoading = true
            let message_last = messages.last
            
            // query to fetch messages
            let query = Chat.query()!
            query.whereKey(Constants.chatRoom, equalTo: chatRoomName)
            // time based pagination
            if let message_last = message_last, let messageDate = message_last.date {
                query.whereKey(Constants.createdAt, greaterThan: messageDate)
            }
            // we need this so we can get the sender's objectId for simplicity
            query.includeKey(Constants.sender)
            // show messages in order sent
            query.order(byAscending: Constants.createdAt)
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    for object in objects! {
                        let chat = object as! Chat
                        self.addMessage(chat: chat)
                    }
                    if !objects!.isEmpty {
                        self.delegate?.finishReceivingMessage()
                    }
                } else if let error = error {
                    print(error)
                }
                self.isLoading = false
            })
        }
    }
    
    func sendMessage(_ text: String) {
        // When they hit send. Save their message.
        let chat = createChat(chatText: text)
        saveChat(chat: chat)
    }
    
    func sendPhotoMessage(text: String, pictureFile: PFFile!) {
        let chat = createChat(chatText: text)
        if let pictureFile = pictureFile {
            chat.chatText = "[Picture message]"
            chat.picture = pictureFile
        }
        saveChat(chat: chat)
    }
    
    fileprivate func saveChat(chat: Chat) {
        addMessage(chat: chat)
        delegate?.finishSendingMessage()
        chat.saveInBackground { (succeeded, error) -> Void in
            if succeeded {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
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
    
    fileprivate func addMessage(chat: Chat) {
        var message: JSQMessage!
        
        let user = chat.sender
        
        if let chatPicture = chat.picture {
            
            let mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem?.appliesMediaViewMaskAsOutgoing = user.objectId! == User.current()!.objectId!
            message = JSQMessage(senderId: user.objectId, senderDisplayName: user.fullName, date: chat.createdAt ?? Date(), media: mediaItem)
            
            chatPicture.getDataInBackground(block: { (imageData, error) -> Void in
                if error == nil {
                    mediaItem?.image = UIImage(data: imageData!)
                    self.delegate?.reloadCollectionView()
                }
            })
        }else {
            message = JSQMessage(senderId: user.objectId, senderDisplayName: user.fullName, date: chat.createdAt ?? Date(), text: chat.chatText)
        }
        delegate?.appendMessage(message: message)
    }

}

protocol ChatDataStoreDelegate {
    func finishReceivingMessage()
    func finishSendingMessage()
    func cacheUserObject(_ user: User, objectID: String)
    func reloadCollectionView()
    func appendMessage(message: JSQMessage)
}

extension ChatViewController: ChatDataStoreDelegate {
    func cacheUserObject(_ user: User, objectID: String) {
        self.users[objectID] = user
    }
    
    func reloadCollectionView() {
        self.collectionView.reloadData()
    }
    
    func appendMessage(message: JSQMessage) {
        self.messages.append(message)
    }
}
