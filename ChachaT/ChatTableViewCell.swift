//
//  ChatTableViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    var theNameLabel : UILabel = UILabel()
    var theCircleView : CircleView!
    var theTimeStamp : UILabel = UILabel()
    
    var user: User!
    var chat: Chat!
    
    init(chat: Chat) {
        super.init(style: .Default, reuseIdentifier: "chatTableViewCell")
        self.user = chat.sender
        self.chat = chat
        profileCircleSetup()
        timeStampSetup(NSDate())
        if let name = user.fullName {
            nameLabelSetup(name)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func profileCircleSetup() {
        //TODO: the diameter for this should be the same as the diameter for the scrolling matches view
        let diameter : CGFloat = self.frame.width * 0.2
        theCircleView = CircleView(file: user.profileImage, diameter: diameter)
        self.addSubview(theCircleView)
        theCircleView.snp_makeConstraints { (make) in
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
            make.top.equalTo(theCircleView).offset(10)
            make.leading.equalTo(theCircleView.snp_trailing)
            make.trailing.equalTo(theTimeStamp.snp_leading)
        }
    }
    
    //TODO: set the timestamp to a real time
    func timeStampSetup(time: NSDate) {
        theTimeStamp.text = "12"
        self.addSubview(theTimeStamp)
        theTimeStamp.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            //TODO: probably should make the width and heights to a constraint
            make.width.equalTo(30)
        }
    }
    
    

}
