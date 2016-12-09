//
//  OverlayIndicatorView.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import EZSwiftExtensions

class OverlayIndicatorView: CircularImageView {
    fileprivate struct OverlayConstants {
        static let width: CGFloat = 100
        static let maxWidth: CGFloat = 150
        static let leftImage: UIImage = #imageLiteral(resourceName: "filledInSkipButton")
        static let rightImage: UIImage = #imageLiteral(resourceName: "filledInApproveButton")
    }
    
    enum Side {
        case left
        case right
    }
    
    override var frame: CGRect {
        didSet {
            isHidden = frame == originalFrame
        }
    }
    
    var widthDifference: CGFloat {
        get {
            return OverlayConstants.maxWidth - originalFrame.width
        }
    }
    
    var originalFrame: CGRect {
        get {
            let minX = side == .left ? -OverlayConstants.width : ez.screenWidth + OverlayConstants.width
            return CGRect(x: minX, y: superview?.frame.midY ?? ez.screenHeight / 2, width: OverlayConstants.width, height: OverlayConstants.width)
        }
    }

    var side: Side = .left
    
    init(side: Side) {
        super.init(file: side == .left ? OverlayConstants.leftImage : OverlayConstants.rightImage, diameter: OverlayConstants.width)
        self.side = side
        self.frame = originalFrame
        self.layer.zPosition = CGFloat.greatestFiniteMagnitude
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func revertToOriginalPosition() {
        self.frame = originalFrame
    }
}
