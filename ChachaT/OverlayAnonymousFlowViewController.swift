//
//  OverlayAnonymousFlowViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class OverlayAnonymousFlowViewController: UIViewController {
    var theOverlayView: UIView = UIView()
    var rippleState = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        animateOverlay(theOverlayView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createSemiTranslucentBlackOverlay(subviews: [UIView]) {
        theOverlayView = createBackgroundOverlay()
        self.view.addSubview(theOverlayView)
        theOverlayView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        for subview in subviews {
            theOverlayView.addSubview(subview)
        }
    }
    
    func removeOverlay() {
        theOverlayView.removeFromSuperview()
    }
}
