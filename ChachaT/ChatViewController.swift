//
//  ChatViewController.swift
//  ElevenDates
//
//  Created by Brett Keck on 5/29/15.
//  Copyright (c) 2015 Brett Keck. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    // to check for new messages
    var timer : Timer!
    // to prevent stomping on our own feet and double loading
    var isLoading = false
    
    // identifier for this room. scalable to mutiple users
    var chatroom = ""
    
    // currently only setup for two participants
    var currentUser : User!
    var otherUser : User!
    
    // Key - value collection of avatars so we don't double load too much
    var avatars = [String:JSQMessagesAvatarImage]()
    // Array of messages
    var messages = [JSQMessage]()
    // Key - value collection of users
    var users = [String:User]()
    
    // chat bubbles for our conversation
    var outgoingBubbleImageView : JSQMessagesBubbleImage!
    var incomingBubbleImageView : JSQMessagesBubbleImage!
    
    var dataStore: ChatDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataStore = ChatDataStore(delegate: self)
        
        self.title = "Chat"
        
        self.senderId = dataStore.getsenderID()
        self.senderDisplayName = dataStore.getSenderDisplayName()
        self.chatroom = dataStore.getChatRoomName(otherUser)
        
        // setup chat bubbles
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        incomingBubbleImageView = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        self.loadMessages()
        
        // We check for new messages every 5 seconds
        //Terrance Kunstek said this is a memory leak because when viewcontroller is dropped, the timer keeps going. He has code to fix this. 
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ChatViewController.loadMessages), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView!.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // when they leave this screen, stop checking for messages
        timer.invalidate()
    }
    
    func loadMessages() {
        dataStore.loadMessages(messages)
    }
    
//    func loadMessages() {
//        if !isLoading {
//            isLoading = true
//            let message_last = messages.last
//            
//            // query to fetch messages
//            let query = Chat.query()!
//            query.whereKey(Constants.chatRoom, equalTo: chatroom)
//            // time based pagination
//            if message_last != nil {
//                query.whereKey(Constants.createdAt, greaterThan: message_last!.date)
//            }
//            // we need this so we can get the sender's objectId for simplicity
//            query.includeKey(Constants.sender)
//            // show messages in order sent
//            query.orderByAscending(Constants.createdAt)
//            query.findObjectsInBackgroundWithBlock({ (objects, error) in
//                if error == nil {
//                    for object in objects! {
//                        // Go through each Chat message and create a
//                        // JSQMessage for display on this screen
//                        let chat = object as! Chat
//                        let message = JSQMessage(senderId: chat.sender.objectId, senderDisplayName: chat.sender.fullName, date: chat.createdAt, text: chat.chatText)
//                        
//                        self.messages.append(message)
//                        
//                        // just ensure we cache the user object for later
//                        self.users[chat.sender.objectId!] = chat.sender
//                    }
//                    if !objects!.isEmpty {
//                        self.finishReceivingMessage()
//                    }
//                }
//                self.isLoading = false
//            })
//            
//        }
//        
//    }
    
    // Mark - JSQMessagesViewController method overrides
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        dataStore.sendMessage(text, otherUser: otherUser)
    }
    
    // Mark - JSQMessages CollectionView DataSource
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        // return message for current row
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        // show correct avatar for message sent
        
        let message = messages[indexPath.item]
        if self.avatars[message.senderId] == nil {
            let imageView = JSQMessagesAvatarImage(placeholder: UIImage(named: "DrivingGirl"))
            self.avatars[message.senderId] = imageView
            
            
            //TODO: abstract this thing to data store, but I am not exactly sure how to at the moment.
            let user = users[message.senderId]!
            user.profileImage!.getDataInBackground { (data, error) in
                imageView?.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(data:data!), withDiameter: 30)
                // Hack: For reload entire table now that avatar is downloaded
                self.collectionView!.reloadData()
            }
        }
        
        return self.avatars[message.senderId];
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        // show date stamp every 3 records.
        if indexPath.item % 3 == 0
        {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil;
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        // Show the name every once and a while
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId
        {
            return nil
        }
        
        if indexPath.item - 1 > 0
        {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId
            {
                return nil
            }
        }
        
        return NSAttributedString(string: otherUser.fullName!)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // Mark - UICollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Grab cell we are about to show
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        // Customize it some
        let message = messages[(indexPath as NSIndexPath).item]
        if message.senderId == self.senderId
        {
            cell.textView!.textColor = UIColor.black
        }
        else
        {
            cell.textView!.textColor = UIColor.white
        }
        
        return cell;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        // if we are going to show the date/time, give it some height
        if indexPath.item % 3 == 0
        {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        // more height logic
        let message = messages[indexPath.item]
        if message.senderId == self.senderId
        {
            return 0.0
        }
        
        if indexPath.item - 1 > 0
        {
            let previousMessage = messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId
            {
                return 0.0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        // more height logic
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("tapped load earlier messages - need implementation")
    }
}
