//
//  FilterViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/1/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var theRaceAsianButton: UIButton!
    @IBOutlet weak var theRaceBlackButton: UIButton!
    @IBOutlet weak var theRaceLatinoButton: UIButton!
    @IBOutlet weak var theRaceWhiteButton: UIButton!
    @IBOutlet weak var theRaceAllButton: UIButton!
    @IBOutlet weak var theRaceStackView: UIStackView!
    @IBOutlet weak var theContentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewDidLayoutSubviews() {
        createBackgroundView(theRaceStackView)
        maskButton(theRaceAsianButton, leftButton: true)
        maskButton(theRaceAllButton, leftButton: false)
    }
    
    func createBackgroundView(stackView: UIStackView) {
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = FilteringPageStackViewLinesColor
        self.theContentView.insertSubview(backgroundColorView, belowSubview: stackView)
        backgroundColorView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(stackView).inset(UIEdgeInsetsMake(0, 20, 0, 20))
        }
    }
    
    //left button means we want the corners to be on the top and bottom left. If false, then we want right side corners.
    func maskButton(button: UIButton, leftButton: Bool) {
        let cornerSize : CGFloat = 10
        let maskLayer = CAShapeLayer()
        if leftButton {
             maskLayer.path = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: UIRectCorner.TopLeft.union(.BottomLeft), cornerRadii: CGSizeMake(cornerSize, cornerSize)).CGPath
            
            
        } else {
            //button is on the right side
            maskLayer.path = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: UIRectCorner.TopRight.union(.BottomRight), cornerRadii: CGSizeMake(cornerSize, cornerSize)).CGPath
        }
        
        button.layer.mask = maskLayer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
