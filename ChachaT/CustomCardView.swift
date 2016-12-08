//
//  CustomCardView.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Koloda
import ParseUI

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"

class CustomCardView: OverlayView {
    //TODO: get rid of this pfIMageView and replace with more non-dependent UIImageView
    @IBOutlet weak var theCardMainImage: PFImageView!
    @IBOutlet weak var thePersonalInfoHolderView: UIView!
    @IBOutlet weak var theDescriptionDetailView: DescriptionDetailView!
    var theVertSlideView: VerticalSlideShowView?
    
    var userOfTheCard : User? {
        didSet {
            if let user = userOfTheCard {
                vertSlideShowViewSetup(user: user)
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            if let view = theVertSlideView {
                view.frame = self.bounds
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Rounded corners
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }
    
    fileprivate func vertSlideShowViewSetup(user: User) {
        theVertSlideView = VerticalSlideShowView(imageFiles: user.nonNilProfileImages, frame: self.bounds)
        self.addSubview(theVertSlideView!)
    }
}

