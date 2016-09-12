//
//  AnnotationView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class AnnotationView: Circle {
    private struct AnnotationConstants {
        static let imageToCircleRatio : CGFloat = 0.75
    }
    
    init(diameter: CGFloat, color: UIColor, imageName: String) {
        super.init(diameter: diameter, color: color)
        imageViewSetup(imageName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewSetup(imageName: String) {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .ScaleAspectFit
        self.addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
            make.center.equalTo(self)
            make.height.equalTo(self.frame.height * AnnotationConstants.imageToCircleRatio)
            make.width.equalTo(self.frame.width * AnnotationConstants.imageToCircleRatio)
        }
    }
}
