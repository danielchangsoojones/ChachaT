//
//  FilterViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/1/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import TTRangeSlider

class FilterViewController: UIViewController {
    
    @IBOutlet weak var theRaceAsianButton: UIButton!
    @IBOutlet weak var theRaceBlackButton: UIButton!
    @IBOutlet weak var theRaceLatinoButton: UIButton!
    @IBOutlet weak var theRaceWhiteButton: UIButton!
    @IBOutlet weak var theRaceAllButton: UIButton!
    @IBOutlet weak var theRaceStackView: UIStackView!
    @IBOutlet weak var theContentView: UIView!
    @IBOutlet weak var theRaceHolderView: UIView!
    @IBOutlet weak var theDistanceSlider: UISlider!
    @IBOutlet weak var theDistanceMilesLabel: UILabel!
    @IBOutlet weak var theDistanceGraySliderView: UIView!
    @IBOutlet weak var theAgeRangeSlider: TTRangeSlider!
    @IBOutlet weak var theAgeRangeLabel: UILabel!
    @IBOutlet weak var theHairColorBrunetteButton: UIButton!
    @IBOutlet weak var theHairColorRedheadButton: UIButton!
    @IBOutlet weak var theHairColorBlondeButton: UIButton!
    @IBOutlet weak var theHairColorAllButton: UIButton!
    @IBOutlet weak var theHairColorStackView: UIStackView!
    @IBOutlet weak var theHairColorHolderView: UIView!
    
    let cornerSize : CGFloat = 10
    
    @IBAction func distanceSliderValueChanged(sender: AnyObject) {
        let distanceValue = round(theDistanceSlider.value)
        theDistanceMilesLabel.text = "\(Int(distanceValue)) mi."
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setAgeSliderGUI()
    }
    
    func setAgeSliderGUI() {
        theAgeRangeSlider.tintColor = PeriwinkleGray
        theAgeRangeSlider.tintColorBetweenHandles = ChachaTeal
        theAgeRangeSlider.handleDiameter = 27
        theAgeRangeSlider.selectedHandleDiameterMultiplier = 1.2
    }
    
    override func viewDidLayoutSubviews() {
        createBackgroundView(theRaceStackView, holderView: theRaceHolderView)
        createBackgroundView(theHairColorStackView, holderView: theHairColorHolderView)
        maskButton(theHairColorBrunetteButton, leftButton: true)
        maskButton(theHairColorAllButton, leftButton: false)
        maskButton(theRaceAsianButton, leftButton: true)
        maskButton(theRaceAllButton, leftButton: false)
        theDistanceGraySliderView.layer.cornerRadius = cornerSize
        theAgeRangeSlider.layer.cornerRadius = cornerSize
    }
    
    //for creating the lines between the buttons. I create spacing with the stack view and then place a view with background color behind it to fill in the spaces.
    func createBackgroundView(stackView: UIStackView, holderView: UIView) {
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = FilteringPageStackViewLinesColor
        holderView.insertSubview(backgroundColorView, belowSubview: stackView)
        backgroundColorView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(stackView).inset(UIEdgeInsetsMake(0, 20, 0, 20))
        }
    }
    
    //left button means we want the corners to be on the top and bottom left. If false, then we want right side corners.
    func maskButton(button: UIButton, leftButton: Bool) {
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


extension FilterViewController: TTRangeSliderDelegate {
    func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        let ageMaxValue = round(theAgeRangeSlider.selectedMaximum)
        let ageMinValue = round(theAgeRangeSlider.selectedMinimum)
        if ageMaxValue >= 65 {
            theAgeRangeLabel.text = "\(Int(ageMinValue)) - \(Int(ageMaxValue))+"
        } else {
            theAgeRangeLabel.text = "\(Int(ageMinValue)) - \(Int(ageMaxValue))"
        }
    }
}
