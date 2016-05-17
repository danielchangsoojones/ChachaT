//
//  CardDetailSuperViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/16/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class CardDetailSuperViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setBottomBlur()
        // Do any additional setup after loading the view.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setBottomBlur() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - 100, width:  UIScreen.mainScreen().bounds.width, height: 100)
        let transparent = UIColor(white: 1, alpha: 0).CGColor
        let opaque = UIColor.rgba(red: 1, green: 195, blue: 167, alpha: 0.5).CGColor
        gradientLayer.colors = [transparent, opaque]
        gradientLayer.locations = [0.0, 0.8]
        
        self.view.layer.addSublayer(gradientLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
