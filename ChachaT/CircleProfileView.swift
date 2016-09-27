//
//  CircleProfileView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CircleProfileView: UIView {
    fileprivate struct ProfileViewConstants {
        static let circleViewCenterOffset: CGFloat = -10
    }
    
    let theNameLabel = UILabel()
    var circleView: CircleView!
    
    //TODO: set the intrinsic content size to calculate correctly
    init(frame: CGRect, name: String, imageFile: AnyObject) {
        super.init(frame: frame)
        let diameter = frame.size.width
        circleViewSetup(diameter, file: imageFile)
        nameLabelSetup(name)
    }
    
    //TODO: right now, I am ust using a constant to make an offset to show the name label, but I could probably be more exact about things.
    func circleViewSetup(_ diameter: CGFloat, file: AnyObject) {
        circleView = CircularImageView(file: file, diameter: diameter)
        self.addSubview(circleView)
        circleView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(ProfileViewConstants.circleViewCenterOffset)
        }
    }
    
    func nameLabelSetup(_ name: String) {
        theNameLabel.text = name
        theNameLabel.lineBreakMode = .byClipping
        theNameLabel.font = ChatCellConstants.nameLabelFont
        self.addSubview(theNameLabel)
        theNameLabel.snp.makeConstraints { (make) in
            //TODO: put these constants in a struct
            make.top.equalTo(circleView.snp.bottom)
            make.centerX.equalTo(self)
            make.width.lessThanOrEqualTo(circleView)
        }
    }
    
    func getLabelTitle() -> String? {
        return theNameLabel.text
    }
    
    func setLabelColor(color: UIColor) {
        theNameLabel.textColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize : CGSize {
        //need to override because usually UIViews have no intrinsic content size.
        //But, we want the stackViews to size the view according to their frames, so we need to actually make the intrinsicContentSize = the frame of the View
        //.FillProportionatly of stackview sizes things based upon their intrinsicContentSize.
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    
}
