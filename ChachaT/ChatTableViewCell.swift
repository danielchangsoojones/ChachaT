//
//  ChatTableViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Timepiece

class ChatTableViewCell: UITableViewCell {
    
    var theNameLabel : UILabel = UILabel()
    var theCircleImageView : CircularImageView!
    var theTimeStamp : UILabel = UILabel()
    var theMessagePreviewLabel : UILabel = UILabel()
    var theUnreadNotificationBubble : CircleView!
    
    var user: User!
    var chat: Chat!
    
    init(chat: Chat) {
        super.init(style: .Default, reuseIdentifier: "chatTableViewCell")
        self.user = chat.sender
        self.chat = chat
        profileCircleSetup()
        timeStampSetup(chat.createdAt!)
        if let name = user.fullName {
            nameLabelSetup(name)
        }
        unreadNotificationBubbleSetup()
        messagePreviewLabelSetup(chat.chatText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func profileCircleSetup() {
        //TODO: the diameter for this should be the same as the diameter for the scrolling matches view
        let diameter : CGFloat = self.frame.width * 0.2
        theCircleImageView = CircularImageView(file: user.profileImage, diameter: diameter)
        self.addSubview(theCircleImageView)
        theCircleImageView.snp_makeConstraints { (make) in
            make.centerY.equalTo(self)
            //TODO: make this offset make it line up with the other matches scroll view bubbles
            make.leading.equalTo(self).offset(10)
            //need to explicitly set height
            make.width.height.equalTo(diameter)
        }
    }
    
    func nameLabelSetup(name: String) {
        theNameLabel.text = name
        self.addSubview(theNameLabel)
        theNameLabel.snp_makeConstraints { (make) in
            //TODO: line up the top of timestamp and the top of the nameLabel
            make.top.equalTo(theCircleImageView).offset(10)
            make.leading.equalTo(theCircleImageView.snp_trailing)
            make.trailing.equalTo(theTimeStamp.snp_leading)
        }
    }
    
    //TODO: set the timestamp to a real time
    func timeStampSetup(dateCreated: NSDate) {
        theTimeStamp.text = formatTimeStamp(dateCreated)
        self.addSubview(theTimeStamp)
        theTimeStamp.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            //TODO: make the width have a high priority for growing or whatever
            make.width.equalTo(100)
        }
    }
    
    func formatTimeStamp(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        let lessThan24Hours : Bool = date >= 1.day.ago
        if lessThan24Hours {
            formatter.dateFormat = "h:mm a"
            formatter.AMSymbol = "AM"
            formatter.PMSymbol = "PM"
            let dateString = formatter.stringFromDate(date) //ex: "10:15 AM"
            return dateString
        } else {
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            let dateString = formatter.stringFromDate(date) //ex: "Sep 10, 2015"
            return dateString
        }
    }
    
    func messagePreviewLabelSetup(message: String) {
        theMessagePreviewLabel.text = message
        self.addSubview(theMessagePreviewLabel)
        theMessagePreviewLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(theNameLabel)
            make.top.equalTo(theNameLabel.snp_bottom)
            make.trailing.equalTo(theUnreadNotificationBubble)
        }
    }
    
    func unreadNotificationBubbleSetup() {
        let diameter : CGFloat = 10
        theUnreadNotificationBubble = CircleView(diameter: diameter, color: CustomColors.JellyTeal)
        self.addSubview(theUnreadNotificationBubble)
        theUnreadNotificationBubble.snp_makeConstraints { (make) in
            make.top.equalTo(theTimeStamp.snp_bottom)
            make.trailing.equalTo(self)
        }
        theUnreadNotificationBubble.hidden = chat.readByReceiver //if the user has already read this message, then don't show the unread bubble
    }
}
