//
//  ScrollingMatchesTableViewCell.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class ScrollingMatchesTableViewCell: UITableViewCell {
    
    init() {
        //TODO: put the reuse identifier in a global place
        super.init(style: .Default, reuseIdentifier: "hi")
        matchesScrollViewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func matchesScrollViewSetup() {
        let matchesScrollView = AutoGrowingHorizontalScrollView()
        self.addSubview(matchesScrollView)
        matchesScrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        print(self.frame)
        let circleProfileViewFrame = CGRect(x: 0, y: 0, w: 20, h: 20)
        let circle = CircleProfileView(frame: circleProfileViewFrame, name: "Daniel", imageFile: User.currentUser()!.profileImage!)
        let label = UILabel()
        label.text = "booyah"
        matchesScrollView.addView(circle)
        matchesScrollView.addView(label)
    }

}
