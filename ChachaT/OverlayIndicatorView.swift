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
        static let width: CGFloat = 75
        static let leftImage: UIImage = #imageLiteral(resourceName: "OverlayIndicatorLeftButton")
        static let rightImage: UIImage = #imageLiteral(resourceName: "OverlayIndicatorRightButton")
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
    
    var originalFrame: CGRect {
        get {
            let minX = side == .left ? -OverlayConstants.width : ez.screenWidth + OverlayConstants.width
            return CGRect(x: minX, y: superview?.frame.midY ?? ez.screenHeight / 2, width: OverlayConstants.width, height: OverlayConstants.width)
        }
    }
    
    var maxFrame: CGRect {
        get {
            let sideDimension: CGFloat = originalFrame.width * 2
            let maxThreshold: CGFloat = 0.3
            let minX = side == .left ? ez.screenWidth * maxThreshold : ez.screenWidth * (1 - maxThreshold) - sideDimension
            return CGRect(x: minX, y: originalFrame.y - sideDimension / 2, w: sideDimension, h: sideDimension)
        }
    }

    var side: Side = .left
    
    init(side: Side) {
        super.init(file: side == .left ? OverlayConstants.leftImage : OverlayConstants.rightImage, diameter: OverlayConstants.width)
        self.side = side
        self.frame = originalFrame
        self.layer.zPosition = CGFloat.greatestFiniteMagnitude
        self.backgroundColor = UIColor.clear
        snapImageToSides()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func revertToOriginalPosition() {
        self.frame = originalFrame
    }
    
    func snapImageToSides() {
        //we need to snap the imageView to the side, so it grows as the overlay is scaled
        theImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
}
