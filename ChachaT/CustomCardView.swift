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
    @IBOutlet weak var thePersonalInfoHolderView: UIView!
    
    var userOfTheCard : User? {
        didSet {
            if let title = userOfTheCard?.title {
                theTitleLabel.text = title
            }
            if let fullName = userOfTheCard?.fullName {
                theFullNameLabel.text = fullName
            }
            if let age = userOfTheCard?.age {
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
        
        //Rounded corners
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
        //TODO: I just want the border to go around thePersonalInfoHolderView, but right now, it is going around the whole card because I coluld not figure out how to do that. 
        self.layer.borderColor = CustomColors.BombayGrey.cgColor
        self.layer.borderWidth = 0.5
    }
}

