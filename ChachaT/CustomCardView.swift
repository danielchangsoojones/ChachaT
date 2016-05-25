//
//  CustomCardView.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"

protocol CustomCardViewDelegate:class {
    func didTapImage(img:UIImage)
}

class CustomCardView: OverlayView {
    @IBOutlet weak var theCardMainImage: UIImageView!
    @IBOutlet weak var theFullNameLabel: UILabel!
    @IBOutlet weak var theAgeLabel: UILabel!
    @IBOutlet weak var theTitleLabel: UILabel!
    
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
            
        }
    }
    
    weak var delegate:CustomCardViewDelegate?
    var didEndDragging = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

