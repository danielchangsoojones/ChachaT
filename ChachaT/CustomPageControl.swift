//
//  CustomPageControl.swift
//  BumbleTesting
//
//  Created by Daniel Jones on 12/7/16.
//  Copyright © 2016 Daniel Jones. All rights reserved.
//

import Foundation
import UIKit
import EZSwiftExtensions

class CustomPageControl: FilledPageControl {
    override var pageCount: Int {
        didSet {
            makeLastBubbleColor()
        }
    }
    
    override var progress: CGFloat {
        didSet {
            previousProgress = oldValue
        }
    }
    
    var previousProgress: CGFloat = 0 {
        didSet (oldValue) {
            if previousProgress == progress {
                //when we are sliding the cardDetailView, don't let it slide and set the previous progress to itself because then it would go back to its own bubble when we dismiss it. This protects that. 
                previousProgress = oldValue
            }
        }
    }
    
    private enum Orientation {
        case vertical
        case horizontal
    }
    
    private let orientation: Orientation = .vertical
    
    init(numberOfPages: Int) {
        super.init(frame: CGRect.zero)
        tintColor = UIColor.white
        pageCount = numberOfPages
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeLastBubbleColor() {
        if let lastLayer = inactiveLayers.last {
            lastLayer.backgroundColor = CustomColors.JellyTeal.cgColor
        }
    }
    
    override func layoutPageIndicators(_ layers: [CALayer]) {
        if orientation == .horizontal {
            super.layoutPageIndicators(layers)
        } else if orientation == .vertical {
            let layerDiameter = indicatorRadius * 2
            var layerFrame = CGRect(x: 0, y: 0, width: layerDiameter, height: layerDiameter)
            layers.forEach() { layer in
                //Daniel Jones added this. Idk why, but when I moved this code over to shuffle from bumble-app-clone, it turned layer into a tuple
                layer.1.cornerRadius = self.indicatorRadius
                layer.1.frame = layerFrame
                layerFrame.origin.y += layerDiameter + indicatorPadding
            }
        }
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        switch orientation {
        case .horizontal:
            return super.sizeThatFits(size)
        case .vertical:
            let layerDiameter = indicatorRadius * 2
            return CGSize(width: layerDiameter,
                          height: CGFloat(inactiveLayers.count) * layerDiameter + CGFloat(inactiveLayers.count - 1) * indicatorPadding)
        }
    }
}
