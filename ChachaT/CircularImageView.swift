//
//  CircularImageView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CircularImageView: CircleView {
    var theImageView = UIImageView()
    
    init(file: AnyObject?, diameter: CGFloat) {
        let noVisibleImageColor : UIColor = UIColor.gray
        super.init(diameter: diameter, color: noVisibleImageColor)
        imageViewSetup(diameter)
        if let image = file as? UIImage {
            theImageView.image = image
        } else {
            theImageView.loadFromFile(file)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewSetup(_ diameter: CGFloat) {
        self.addSubview(theImageView)
        theImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.height.width.equalTo(diameter)
        }
    }
    
}
