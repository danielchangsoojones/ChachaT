//
//  AgeDoubleRangeSliderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/23/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit
import TTRangeSlider

class AgeDoubleRangeSliderView: UIView {
    let theAgeRangeLabel = UILabel()
    let theAgeRangeSlider = TTRangeSlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createAgeRangeSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createAgeRangeSlider() {
        theAgeRangeSlider.maxValue = 65
        theAgeRangeSlider.minValue = 18
        theAgeRangeSlider.selectedMaximum = 65
        theAgeRangeSlider.selectedMinimum = 19
        theAgeRangeSlider.maxLabelColour = ChachaTeal
        theAgeRangeSlider.minLabelColour = ChachaTeal
        theAgeRangeSlider.minDistance = 0
        theAgeRangeSlider.tintColor = PeriwinkleGray
        theAgeRangeSlider.tintColorBetweenHandles = ChachaTeal
        theAgeRangeSlider.handleDiameter = 27
        theAgeRangeSlider.selectedHandleDiameterMultiplier = 1.2
        self.addSubview(theAgeRangeSlider)
        theAgeRangeSlider.delegate = self
        theAgeRangeSlider.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
}

extension AgeDoubleRangeSliderView: TTRangeSliderDelegate {
    func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
//        let ageMaxValue = round(theAgeRangeSlider.selectedMaximum)
//        let ageMinValue = round(theAgeRangeSlider.selectedMinimum)
    }
}
