//
//  CornerAnnotationView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CornerAnnotationView: UIView {
    init() {
        super.init(frame: CGRectMake(0, 0, 20, 20))
        makeViewCircular()
        createDownArrowImageView(ImageNames.DownArrow)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createDownArrowImageView(imageName: String) {
        let arrowImageView = UIImageView(image: UIImage(named: imageName))
        self.addSubview(arrowImageView)
        arrowImageView.snp_makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(self.frame.width * 0.75)
            make.height.equalTo(self.frame.height * 0.75)
        }
    }
    
    func makeViewCircular() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
        self.backgroundColor = backgroundColor
    }
}
