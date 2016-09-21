//
//  AnnotationView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class AnnotationView: CircleView {
    private struct AnnotationConstants {
        static let imageToCircleRatio : CGFloat = 0.75
    }
    
    private var theImageView: UIImageView!
    
    init(diameter: CGFloat, color: UIColor, imageName: String) {
        super.init(diameter: diameter, color: color)
        imageViewSetup(imageName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageViewSetup(imageName: String) {
        theImageView = UIImageView(image: UIImage(named: imageName))
        theImageView.contentMode = .ScaleAspectFit
        self.addSubview(theImageView)
        theImageView.snp_makeConstraints { (make) in
            make.center.equalTo(self)
            make.height.width.equalTo(self).multipliedBy(AnnotationConstants.imageToCircleRatio)
        }
    }
    
    func updateImage(imageName: String) {
        theImageView.image = UIImage(named: imageName)
    }
}
