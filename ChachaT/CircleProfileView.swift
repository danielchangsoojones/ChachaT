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
    var circleView: CircleView!
    
    //TODO: set the intrinsic content size to calculate correctly
    init(frame: CGRect, name: String, imageFile: AnyObject) {
        super.init(frame: frame)
        let diameter = frame.size.width
        circleViewSetup(diameter, file: imageFile)
        nameLabelSetup(name)
    }
    
    func circleViewSetup(diameter: CGFloat, file: AnyObject) {
        circleView = CircularImageView(file: file, diameter: diameter)
        self.addSubview(circleView)
        circleView.snp_makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    //TODO: make the name label resize so it doesn't go over the screen
    func nameLabelSetup(name: String) {
        theNameLabel.text = name
        self.addSubview(theNameLabel)
        theNameLabel.snp_makeConstraints { (make) in
            //TODO: put these constants in a struct
            make.top.equalTo(circleView.snp_bottom)
            make.centerX.equalTo(self)
        }
    }
    
    func getLabelTitle() -> String? {
        return theNameLabel.text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        //need to override because usually UIViews have no intrinsic content size.
        //But, we want the stackViews to size the view according to their frames, so we need to actually make the intrinsicContentSize = the frame of the View
        //.FillProportionatly of stackview sizes things based upon their intrinsicContentSize.
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    
}
