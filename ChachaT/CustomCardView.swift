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
    @IBOutlet weak var theCardMainImage: PFImageView!
    @IBOutlet weak var thePersonalInfoHolderView: UIView!
    @IBOutlet weak var theDescriptionDetailView: DescriptionDetailView!
    
    var userOfTheCard : User? {
        didSet {
            theDescriptionDetailView.userOfTheCard = userOfTheCard
            if let profileImage = userOfTheCard?.profileImage {
                self.theCardMainImage.file = profileImage
                self.theCardMainImage.loadInBackground()
            } else {
                theCardMainImage.backgroundColor = ChachaBombayGrey
            }
        }
    }
    
    var didEndDragging = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Rounded corners
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }
}

