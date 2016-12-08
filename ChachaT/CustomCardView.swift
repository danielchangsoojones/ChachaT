//
//  CustomCardView.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Koloda

class CustomCardView: OverlayView {
    var theVertSlideView: VerticalSlideShowView!
    
    var userOfTheCard : User? {
        didSet {
            if let user = userOfTheCard {
                vertSlideShowViewSetup(user: user)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Rounded corners
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func vertSlideShowViewSetup(user: User) {
        theVertSlideView = VerticalSlideShowView(imageFiles: user.nonNilProfileImages, frame: self.bounds)
        self.addSubview(theVertSlideView!)
    }
}

