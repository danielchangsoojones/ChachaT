//
//  ScrollingMatchesTableViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

protocol ScrollingMatchesCellDelegate {
    func segueToChatVC(_ otherUser: User)
}

class ScrollingMatchesTableViewCell: UITableViewCell {
    fileprivate struct ScrollingMatchesConstants {
        static let circleRatioToCell : CGFloat = 0.2
        static let fontColor: UIColor = ChatCellConstants.fontColor
    }
    
    var delegate: ScrollingMatchesCellDelegate?
    
    var matches: [Connection] = []
    var matchesScrollView: AutoGrowingHorizontalScrollView = AutoGrowingHorizontalScrollView()
    
    //TODO: make there be some sort of spinner or loading view to show that we are waiting for the server to pulls matches down
    init(matches: [Connection], delegate: ScrollingMatchesCellDelegate) {
        super.init(style: .default, reuseIdentifier: "scrollingMatchesTableViewCell")
        self.matches = matches
        self.delegate = delegate
        matchesScrollViewSetup()
        addProfileCircles(matches)
        lineSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func matchesScrollViewSetup() {
        self.addSubview(matchesScrollView)
        matchesScrollView.snp.makeConstraints { (make) in
            make.trailing.bottom.top.equalTo(self)
            make.leading.equalTo(self).offset(ChatCellConstants.profileImageLeadingOffset)
        }
    }
    
    func addProfileCircles(_ matches: [Connection]) {
        let circleProfileViewFrame = CGRect(x: 0, y: 0, w: self.frame.width * ScrollingMatchesConstants.circleRatioToCell, h: self.frame.height)
        for match in matches {
            if let fullName = match.targetUser.fullName, let profileImage = match.targetUser.profileImage {
                let circleProfileView = CircleProfileView(frame: circleProfileViewFrame, name: fullName, imageFile: profileImage)
                circleProfileView.setLabelColor(color: ScrollingMatchesConstants.fontColor)
                circleProfileView.addTapGesture(action: { (tapped) in
                    self.delegate?.segueToChatVC(match.targetUser)
                })
                matchesScrollView.addView(circleProfileView)
            }
        }
    }
    
    func lineSetup() {
        let line = UIView()
        line.backgroundColor = ChatCellConstants.lineColor
        line.alpha = ChatCellConstants.lineAlpha
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.trailing.bottom.leading.equalTo(self)
            make.height.equalTo(ChatCellConstants.lineHeight)
        }
    }

}
