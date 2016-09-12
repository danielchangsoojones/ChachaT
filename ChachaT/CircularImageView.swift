//
//  CircularImageView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CircularImageView: Circle {
    var theImageView = UIImageView()
    
    init(file: AnyObject?, diameter: CGFloat) {
        let noVisibleImageColor : UIColor = UIColor.grayColor()
        super.init(diameter: diameter, color: noVisibleImageColor)
        imageViewSetup()
        theImageView.loadFromFile(file)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewSetup() {
        self.addSubview(theImageView)
        theImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
}