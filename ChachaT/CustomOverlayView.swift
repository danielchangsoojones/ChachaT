//
//  CustomOverlayView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/27/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

class CustomOverlayView: OverlayView {
    
    @IBOutlet weak var theApproveImage: UIImageView!
    @IBOutlet weak var theSkipImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                theSkipImage.isHidden = false
                theApproveImage.isHidden = true
            case .right? :
                theApproveImage.isHidden = false
                theSkipImage.isHidden = true
            default:
                break
            }
        }
    }

}
