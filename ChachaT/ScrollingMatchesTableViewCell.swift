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
    
    var matches: [Connection] = []
    var matchesScrollView: AutoGrowingHorizontalScrollView = AutoGrowingHorizontalScrollView()
    
    //TODO: make there be some sort of spinner or loading view to show that we are waiting for the server to pulls matches down
    init(matches: [Connection], delegate: ScrollingMatchesCellDelegate) {
        super.init(style: .Default, reuseIdentifier: "scrollingMatchesTableViewCell")
        self.matches = matches
        self.delegate = delegate
        matchesScrollViewSetup()
        addProfileCircles(matches)
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
    
    func addProfileCircles(matches: [Connection]) {
        let circleProfileViewFrame = CGRect(x: 0, y: 0, w: self.frame.width * ScrollingMatchesConstants.circleRatioToCell, h: self.frame.height)
        for match in matches {
            if let fullName = match.targetUser.fullName, profileImage = match.targetUser.profileImage {
                let circleProfileView = CircleProfileView(frame: circleProfileViewFrame, name: fullName, imageFile: profileImage)
                circleProfileView.tapped { (tapped) in
                    self.delegate?.segueToChatVC(match.targetUser)
                }
                matchesScrollView.addView(circleProfileView)
            }
        }
    }

}
