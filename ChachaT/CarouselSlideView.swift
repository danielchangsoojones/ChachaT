//
//  CarouselSlideView.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/31/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import TGLParallaxCarousel

class CarouselSlideView: TGLParallaxCarouselItem {
    fileprivate var theImageView: UIImageView = UIImageView()
    
    init(file: AnyObject?, frame: CGRect) {
        super.init(frame: frame)
        imageViewSetup(file: file)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func imageViewSetup(file: AnyObject?) {
        theImageView.loadFromFile(file)
        self.addSubview(theImageView)
        theImageView.backgroundColor = UIColor.red
        //Can't use snapkit to pin the image to the edges for some reason, but setting the frame to the bounds does the job
        theImageView.frame = self.bounds
    }
}
