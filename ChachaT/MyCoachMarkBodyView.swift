//
//  MyCoachMark.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/1/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Instructions
import EZSwiftExtensions

class MyCoachMarkBodyView: UIView, CoachMarkBodyView {
    var nextControl: UIControl? {
        get {
            return nil
        }
    }
    
    weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate? = nil
    
    
    init(title: String) {
        super.init(frame: CGRect(x: 0, y: 0, w: ez.screenWidth * 0.6, h: ez.screenHeight * 0.25))
        labelSetup(title: title)
    }
    
    private func labelSetup(title: String) {
        let label = UILabel()
        label.numberOfLines = 3
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont(name: "Marker Felt", size: 80)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //Will only donwsize the font to fit, won't upsize it. 
        label.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
