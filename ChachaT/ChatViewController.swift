//
//  ChatViewController.swift
//  ElevenDates
//
//  Created by Brett Keck on 5/29/15.
//  Copyright (c) 2015 Brett Keck. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import EZSwiftExtensions
import Parse

class ChatViewController: JSQMessagesViewController {
    // to prevent stomping on our own feet and double loading
    var isLoading = false
    
    // currently only setup for two participants
    var currentUser : User!
    var otherUser : User!
    
    // Key - value collection of avatars so we don't double load too much
    var avatars = [String:JSQMessagesAvatarImage]()
    // Array of messages
    var messages = [JSQMessage]()
    // Key - value collection of users
    var users = [String:User]()
    
    //starter swipe is the swipe that start off the conversation if the chatVC was accessed via a swipe message
    var starterSwipe: Swipe?
    
    // chat bubbles for our conversation
    var outgoingBubbleImageView : JSQMessagesBubbleImage!
    var incomingBubbleImageView : JSQMessagesBubbleImage!
    
    var dataStore: ChatDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataStore = ChatDataStore(chatUsers: [currentUser, otherUser] ,delegate: self)
        self.navigationController?.isNavigationBarHidden = false
        rightNavButtonSetup()
        
        self.title = otherUser.fullName ?? "Unknown"
        
        self.senderId = dataStore.getsenderID()
        self.senderDisplayName = dataStore.getSenderDisplayName()
        
        // setup chat bubbles
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        incomingBubbleImageView = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        self.loadMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView!.collectionViewLayout.springinessEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // when they leave this screen, stop checking for messages
        dataStore.unsubscribeToLiveMessaging()
    }
    
    func loadMessages() {
        dataStore.loadMessages(messages)
    }
    
    // Mark - JSQMessagesViewController method overrides
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        dataStore.sendMessage(text)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.inputToolbar?.contentView?.textView?.resignFirstResponder()
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (alertAction: UIAlertAction) in
            _ = Camera.shouldStartCamera(target: self, canEdit: false, frontFacing: true)
        }
        
        let photoAction = UIAlertAction(title: "Choose existing Photo", style: .default) { (alertAction: UIAlertAction) in
            _ = Camera.shouldStartPhotoLibrary(target: self, canEdit: false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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
        
        return NSAttributedString(string: otherUser.fullName ?? "Unknown")
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
        if let textView = cell.textView {
            textView.textColor = message.senderId == self.senderId ? UIColor.black : UIColor.white
        }
//        if message.senderId == self.senderId
//        {
//            cell.textView!.textColor = UIColor.black
//        }
//        else
//        {
//            cell.textView!.textColor = UIColor.white
//        }
        
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
    
    override func finishReceivingMessage() {
        if let swipe = starterSwipe {
            //if the swipe exists, then we want to append the swipe message onto the last message, so the user can respond to it.
            dataStore.setStarterSwipeMessage(swipe: swipe)
        }
        super.finishReceivingMessage()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func sendMessage(text: String, picture: UIImage?) {
        //TODO: make it so I don't need Parse in my ViewController. I don't even know if I need these lines, but I don;t want to break anything right now. 
        var pictureFile: PFFile!

        if let picture = picture {
            pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(picture, 0.6)!)
            pictureFile.saveInBackground(block: { (suceeded, error) -> Void in
                if let error = error {
                    print(error)
                }
            })
        }
        //This is where we actually send the message in parse to make it save
        dataStore.sendPhotoMessage(text: text, pictureFile: pictureFile)
    }
    
    func didSelectPhotoMessage(image:UIImage) {
        self.sendMessage(text: "", picture: image)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var picture = info[UIImagePickerControllerOriginalImage] as? UIImage
        if picture == nil {
            picture = info[UIImagePickerControllerEditedImage] as? UIImage
        } else {
            self.didSelectPhotoMessage(image: picture!)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

//Navigation buttons extension
extension ChatViewController {
    fileprivate func rightNavButtonSetup() {
        let profileCircle = CircularImageView(file: otherUser.profileImage, diameter: navigationBarHeight * 0.75)
        let tap = UITapGestureRecognizer(target: self, action: #selector(segueToCardDetailVC))
        profileCircle.addGestureRecognizer(tap)
        let barButtonItem = UIBarButtonItem(customView: profileCircle)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func segueToCardDetailVC() {
        let cardDetailVC = CardDetailViewController.createCardDetailVC(userOfCard: otherUser)
        pushVC(cardDetailVC)
    }
}

extension ChatViewController {
    class func instantiate(otherUser: User) -> ChatViewController {
        let chatVC = ChatViewController()
        chatVC.currentUser = User.current()
        chatVC.otherUser = otherUser
        return chatVC
    }
}
