//
//  ChatTableViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Timepiece

struct ChatCellConstants {
    static let infoLeadingOffsetFromProfilePhoto: CGFloat = 10
    static let nameLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 17)
    static let profileImageLeadingOffset: CGFloat = 10
    static let fontColor: UIColor = CustomColors.SilverChaliceGrey
    static let lineAlpha: CGFloat = 0.3
    static let lineColor: UIColor = CustomColors.BombayGrey
    static let lineHeight: CGFloat = 1
}

class ChatTableViewCell: UITableViewCell {
    
    var theNameLabel : UILabel = UILabel()
    var theCircleImageView : CircularImageView!
    var theTimeStamp : UILabel = UILabel()
    var theMessagePreviewLabel : UILabel = UILabel()
    var theUnreadNotificationBubble : CircleView!
    
    var user: User?
    var chatRoom: ChatRoom!
    var newestMessage: Message!
    
    init(chatRoom: ChatRoom) {
        super.init(style: .default, reuseIdentifier: "chatTableViewCell")
        self.user = chatRoom.getOtherUser()
        self.chatRoom = chatRoom
        profileCircleSetup()
        newestMessage = chatRoom.messages[0]
        timeStampSetup(newestMessage.dateSent as Date)
        if let name = user!.fullName {
            nameLabelSetup(name)
        }
        unreadNotificationBubbleSetup()
        messagePreviewLabelSetup(newestMessage.body)
        lineSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func profileCircleSetup() {
        //TODO: the diameter for this should be the same as the diameter for the scrolling matches view
        let diameter : CGFloat = self.frame.width * 0.2
        theCircleImageView = CircularImageView(file: user!.profileImage, diameter: diameter)
        self.addSubview(theCircleImageView)
        theCircleImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            //TODO: make this offset make it line up with the other matches scroll view bubbles
            make.leading.equalTo(self).offset(ChatCellConstants.profileImageLeadingOffset)
            //need to explicitly set height
            make.width.height.equalTo(diameter)
        }
    }
    
    func nameLabelSetup(_ name: String) {
        theNameLabel.text = name
        //TODO: make this number mean something
        theNameLabel.font = ChatCellConstants.nameLabelFont
        theNameLabel.textColor = ChatCellConstants.fontColor
        self.addSubview(theNameLabel)
        theNameLabel.snp.makeConstraints { (make) in
            //TODO: line up the top of timestamp and the top of the nameLabel
            make.top.equalTo(theCircleImageView).offset(10)
            make.leading.equalTo(theCircleImageView.snp.trailing).offset(ChatCellConstants.infoLeadingOffsetFromProfilePhoto)
            make.trailing.equalTo(theTimeStamp.snp.leading)
        }
    }
    
    //TODO: set the timestamp to a real time
    func timeStampSetup(_ dateCreated: Date) {
        theTimeStamp.text = formatTimeStamp(dateCreated)
        theTimeStamp.font = UIFont.systemFont(ofSize: 10)
        theTimeStamp.textColor = ChatCellConstants.fontColor
        //We want the timeStamp to not grow, nor shrink in regards to the size of theNameLabel. theNameLabel, if too long, should be the one to shrink.
        theTimeStamp.sizeToFit()
        theTimeStamp.setContentHuggingPriority(1000, for: .horizontal)
        theTimeStamp.setContentCompressionResistancePriority(1000, for: .horizontal)
        self.addSubview(theTimeStamp)
        theTimeStamp.snp.makeConstraints { (make) in
            make.trailing.equalTo(self)
            //TODO: I want this line up with the Sarah Schwuman center, but can't figure out how to do that.
            make.top.equalTo(theCircleImageView).offset(13)
        }
    }
    
    func formatTimeStamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        let lessThan24Hours : Bool = date >= 1.day.ago ?? Date()
        if lessThan24Hours {
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            let dateString = formatter.string(from: date) //ex: "10:15 AM"
            return dateString
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let dateString = formatter.string(from: date) //ex: "Sep 10, 2015"
            return dateString
        }
    }
    
    func messagePreviewLabelSetup(_ message: String) {
        theMessagePreviewLabel.text = message
        theMessagePreviewLabel.textColor = ChatCellConstants.fontColor
        self.addSubview(theMessagePreviewLabel)
        theMessagePreviewLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(theNameLabel)
            make.top.equalTo(theNameLabel.snp.bottom)
            make.trailing.equalTo(theUnreadNotificationBubble)
        }
    }
    
    //TODO: make it so the messaging has a number to show the number of unread messages
    func unreadNotificationBubbleSetup() {
        let diameter : CGFloat = 15
        theUnreadNotificationBubble = CircleView(diameter: diameter, color: CustomColors.JellyTeal)
        self.addSubview(theUnreadNotificationBubble)
        theUnreadNotificationBubble.snp.makeConstraints { (make) in
            make.top.equalTo(theTimeStamp.snp.bottom).offset(10)
            make.trailing.equalTo(self).inset(10)
        }
        theUnreadNotificationBubble.isHidden = newestMessage.hasBeenRead //if the user has already read this message, then don't show the unread bubble
    }
    
    func lineSetup() {
        let line = UIView()
        line.backgroundColor = ChatCellConstants.lineColor
        line.alpha = ChatCellConstants.lineAlpha
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.leading.equalTo(theCircleImageView.snp.centerX)
            make.trailing.bottom.equalTo(self)
            make.height.equalTo(ChatCellConstants.lineHeight)
        }
    }
}
