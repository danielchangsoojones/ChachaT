//
//  CheckProfileView.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/8/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class CheckProfileView: UIView {
    var theCardView: CustomCardView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        cardSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cardSetup() {
        let inset: CGFloat = 10
        theCardView = CustomCardView(frame: self.bounds.insetBy(dx: inset, dy: inset))
        self.addSubview(theCardView)
    }
    
    func addBackButton(target: UIViewController, selector: Selector) {
        let button = UIButton()
        
    }
}
