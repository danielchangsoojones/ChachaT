//
//  CustomOverlayView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/27/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"

class CustomOverlayView: OverlayView {
    
    @IBOutlet weak var theApproveImage: UIImageView!
    @IBOutlet weak var theSkipImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .Left? :
                theSkipImage.isHidden = false
                theApproveImage.isHidden = true
            case .Right? :
                theApproveImage.isHidden = false
                theSkipImage.isHidden = true
            default:
                break
            }
        }
    }

}
