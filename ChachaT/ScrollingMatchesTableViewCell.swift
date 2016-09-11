//
//  ScrollingMatchesTableViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

protocol ScrollingMatchesCellDelegate {
    func segueToChatVC(otherUser: User)
}

class ScrollingMatchesTableViewCell: UITableViewCell {
    private struct ScrollingMatchesConstants {
        static let circleRatioToCell : CGFloat = 0.2
    }
    
    var delegate: ScrollingMatchesCellDelegate?
    
    var matchedUsers : [User] = []
    var matchesScrollView: AutoGrowingHorizontalScrollView = AutoGrowingHorizontalScrollView()
    
    //TODO: make there be some sort of spinner or loading view to show that we are waiting for the server to pulls matches down
    init(matchedUsers: [User], delegate: ScrollingMatchesCellDelegate) {
        super.init(style: .Default, reuseIdentifier: "scrollingMatchesTableViewCell")
        self.matchedUsers = matchedUsers
        self.delegate = delegate
        matchesScrollViewSetup()
        addProfileCircles(matchedUsers)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func matchesScrollViewSetup() {
        self.addSubview(matchesScrollView)
        matchesScrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func addProfileCircles(users: [User]) {
        let circleProfileViewFrame = CGRect(x: 0, y: 0, w: self.frame.width * ScrollingMatchesConstants.circleRatioToCell, h: self.frame.height)
        for user in matchedUsers {
            if let fullName = user.fullName, profileImage = user.profileImage {
                let circleProfileView = CircleProfileView(frame: circleProfileViewFrame, name: fullName, imageFile: profileImage)
                circleProfileView.tapped { (tapped) in
                    self.delegate?.segueToChatVC(user)
                }
                matchesScrollView.addView(circleProfileView)
            }
        }
    }

}
