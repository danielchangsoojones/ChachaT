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
    let theSliderLabel = UILabel()
    let theSlider = UISlider()
    
    init() {
        super.init(frame: CGRectMake(0, 0, 200, 200))
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
            make.top.equalTo(theSliderLabel.snp_bottom).offset(10)
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
        theSliderLabel.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
        }
    }

}
