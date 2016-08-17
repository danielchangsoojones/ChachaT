//
//  DistanceSliderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/23/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

class SingleSliderView: UIView {
    //TODO: probably need to make the height actually based on something
    let theSliderLabel = UILabel(frame: CGRectMake(0, 0, 0, 20))
    let theSlider = UISlider()
    let sliderOffsetFromLabel : CGFloat = 5
    
    init() {
        super.init(frame: CGRectMake(0, 0, 0, theSliderLabel.frame.height + sliderOffsetFromLabel + theSlider.frame.height))
        createSliderLabel()
        createSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSlider() {
        theSlider.minimumTrackTintColor = ChachaTeal
        theSlider.maximumTrackTintColor = UIColor.whiteColor()
        theSlider.maximumValue = 101
        theSlider.minimumValue = 1
        theSlider.thumbTintColor = UIColor.whiteColor()
        theSlider.continuous = true // false makes it call only once you let go
        theSlider.addTarget(self, action: #selector(SingleSliderView.valueChanged(_:)), forControlEvents: .ValueChanged)
        self.addSubview(theSlider)
        theSlider.snp_makeConstraints { (make) in
            make.trailing.leading.bottom.equalTo(self)
            make.top.equalTo(theSliderLabel.snp_bottom).offset(sliderOffsetFromLabel)
        }
    }
    
    func valueChanged(sender: UISlider) {
        let sliderValue = round(sender.value)
        if sliderValue >= 101 {
            theSliderLabel.text = "100+ mi."
        } else {
            theSliderLabel.text = "\(Int(sliderValue)) mi."
        }
    }
    
    func createSliderLabel() {
        self.addSubview(theSliderLabel)
        theSliderLabel.textColor = UIColor.whiteColor()
        theSliderLabel.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
        }
    }
}
