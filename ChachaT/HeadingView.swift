//
//  HeadingView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class HeadingView: UIView {
    fileprivate struct HeadingViewConstants {
        static let textColor: UIColor = CustomColors.JellyTeal
        static let textFont: UIFont = UIFont.boldSystemFont(ofSize: 20)
        static let numberLabelColor: UIColor = UIColor.white
        static let labelLeadingOffset: CGFloat = 7
    }
    
    var theTitleLabel : UILabel = UILabel()
    var theCircleView : CircleView!
    
    init(text: String, notificationNumber: Int) {
        super.init(frame: CGRect.zero)
        titleLabelSetup(text)
        circleViewSetup(notificationNumber)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func titleLabelSetup(_ text: String) {
        theTitleLabel.text = text
        theTitleLabel.font = HeadingViewConstants.textFont
        theTitleLabel.textColor = HeadingViewConstants.textColor
        self.addSubview(theTitleLabel)
        theTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(HeadingViewConstants.labelLeadingOffset)
            make.centerY.equalTo(self)
        }
    }
    
    //TODO: make the diameter of the circle equal to how big the number width. But, the height needs to be the same as the titleLabel. So probably won't be a circle anymore.
    func circleViewSetup(_ num: Int) {
        let diameter : CGFloat = 20
        theCircleView = CircleView(diameter: diameter, color: HeadingViewConstants.textColor)
        self.addSubview(theCircleView)
        theCircleView.snp.makeConstraints { (make) in
            make.leading.equalTo(theTitleLabel.snp.trailing).offset(HeadingViewConstants.labelLeadingOffset)
            make.centerY.equalTo(self)
        }
        addNumberToCircle(num)
    }
    
    func addNumberToCircle(_ num: Int) {
        let numLabel = UILabel()
        numLabel.text = num.toString
        numLabel.textColor = HeadingViewConstants.numberLabelColor
        theCircleView.addSubview(numLabel)
        numLabel.snp.makeConstraints { (make) in
            make.center.equalTo(theCircleView)
        }
    }
    
    
    
}
