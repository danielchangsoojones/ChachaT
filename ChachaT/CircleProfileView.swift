//
//  CircleProfileView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class CircleProfileView: UIView {
    let theNameLabel = UILabel()
    
    init(name: String) {
        super.init(frame: CGRectZero)
        theNameLabel.text = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
