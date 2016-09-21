//
//  CircleView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    init(diameter: CGFloat, color: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, w: diameter, h: diameter))
        self.backgroundColor = color
        makeCircular(diameter)
        //we need a high priority on content hugging because usually views have a low contentHuggingPriority. Which is why views can grow to the size of their subviews. But, we want the circleView to only grow to its given diameter, and then subviews are just added to this.
        self.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        self.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeCircular(diameter: CGFloat) {
        self.setCornerRadius(radius: (diameter / 2))
        self.clipsToBounds = true
    }
    
    func updateDiameter(diameter: CGFloat) {
        makeCircular(diameter)
        self.frame = CGRect(x: 0, y: 0, w: diameter, h: diameter)
    }
    
    //when the CircleView is shown on superview. This is how it calculates its height and width. Normally, UIView's have no intrinsic contentSize, so needed to be overrided.
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: self.frame.width,height: self.frame.height)
    }
}
