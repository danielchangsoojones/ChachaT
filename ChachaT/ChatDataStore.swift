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
import ParseLiveQuery

let liveQueryClient = ParseLiveQuery.Client()

class ChatDataStore {
    private struct ChatDataStoreConstants {
        static let pictureMessageText = "[Picture message]"
    }
    
    var isLoading = false
    var chatRoomName = ""
    var otherUser: User!
    
    fileprivate var subscription: Subscription<Chat>?
    fileprivate var liveQuery: PFQuery<Chat> = Chat.query()! as! PFQuery<Chat>
    fileprivate var connected: Bool = false
    
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
        
        subscribeToLiveMessaging()
    }
    
    fileprivate func subscribeToLiveMessaging() {
        if connected {
            unsubscribeToLiveMessaging()
        }
        
        liveQuery.whereKey("chatRoom", equalTo: chatRoomName)
        liveQuery.whereKey("senderObjectId", notEqualTo: User.current()!.objectId!)
        
        //The subscription variable has to be held in a global variable, if not, then when the current function finishes running, then it will deallocate the subscription, and the event will NEVER get handled.
        subscription = liveQueryClient.subscribe(liveQuery).handle(Event.created) { (query: PFQuery<Chat>, chat: Chat) in
            self.connected = true
            //ParseLiveQuery is not well made right now, and whenever we try to access chat.picture, the app crashes because for some reason parseLiveQuery doesn't include it. And, you can't run fetchIfNeeded on a PFFIle
            //So, until that gets fixed, we are just having the liveQuery tell us when something has changed, and then we run the query again to actually retrieve. It's ineffecient, but the only way to do it until ParseLveQuery starts working better
            query.includeKey("sender")
            query.whereKey("objectId", equalTo: chat.objectId!)
            query.getFirstObjectInBackground(block: { (chat, error) in
                if let chat = chat {
                    self.addMessage(chat: chat)
                    self.delegate?.finishReceivingMessage()
                } else if let error = error {
                    print(error)
                }
            })
        }
    }
    
    func unsubscribeToLiveMessaging() {
        liveQueryClient.unsubscribe(liveQuery, handler: subscription!)
        connected = false
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
            chat.chatText = ChatDataStoreConstants.pictureMessageText
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
        chat.senderObjectId = User.current()!.objectId! //for parseLiveQuery, we can't query pointer columns, because they haven't updated to this, so need to query the objectId
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
        } else {
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
