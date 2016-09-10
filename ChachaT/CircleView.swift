//
//  CircleView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CircleView : UIView {
    var theImageView = UIImageView()
    
    init(diameter: CGFloat) {
        super.init(frame: CGRectZero)
        imageViewSetup()
        makeCircular(theImageView, diameter: diameter)
    }
    
    convenience init(file: AnyObject?, diameter: CGFloat) {
        self.init(diameter: diameter)
        theImageView.loadFromFile(file)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewSetup() {
        theImageView.backgroundColor = UIColor.grayColor() //in case no picture, it just shows grey
        self.addSubview(theImageView)
        theImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func makeCircular(view: UIView, diameter: CGFloat) {
        theImageView.setCornerRadius(radius: diameter / 2)
        theImageView.clipsToBounds = true
    }
}