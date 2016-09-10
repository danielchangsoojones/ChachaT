//
//  CircleProfileView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CircleProfileView: UIView {
    let theNameLabel = UILabel()
    
    init(name: String, circleViewSize: CGSize, imageFile: AnyObject) {
        super.init(frame: CGRectZero)
        theNameLabel.text = name
        circleViewSetup(circleViewSize, file: imageFile)
    }
    
    func circleViewSetup(size: CGSize, file: AnyObject) {
        let sideDimension : CGFloat = size.width
        //TODO: figure out how to set up cornerRadius for CircleView in the actual circle view class. It will make the code cleaner and more organized.
        let circleView = CircleView(file: User.currentUser()!.profileImage!, cornerRadius: sideDimension / 2)
        self.addSubview(circleView)
        circleView.snp_makeConstraints { (make) in
            make.center.equalTo(self)
            make.height.equalTo(size.height)
            make.width.equalTo(size.width)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
