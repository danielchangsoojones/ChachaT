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
    @IBOutlet weak var theFullNameLabel: UILabel!
    @IBOutlet weak var theAgeLabel: UILabel!
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theCardMainImage: PFImageView!
    
    var userOfTheCard : User? {
        didSet {
            if let title = userOfTheCard?.title {
                theTitleLabel.text = title
            }
            if let fullName = userOfTheCard?.fullName {
                theFullNameLabel.text = fullName
            }
            if let age = userOfTheCard?.calculateBirthDate() {
                theAgeLabel.text = ", " + "\(age)"
            }
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
    }
}

