//
//  DistanceSliderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/23/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

class DistanceSliderView: UIView {
    let theDistanceLabel = UILabel()
    let theDistanceSlider = UISlider()
    
    init() {
        super.init(frame: CGRectMake(0, 0, 200, 200))
        createDistanceLabel()
        createDistanceSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createDistanceSlider() {
        theDistanceSlider.minimumTrackTintColor = ChachaTeal
        theDistanceSlider.maximumTrackTintColor = UIColor.whiteColor()
        theDistanceSlider.maximumValue = 101
        theDistanceSlider.minimumValue = 1
        theDistanceSlider.thumbTintColor = UIColor.whiteColor()
        theDistanceSlider.continuous = true // false makes it call only once you let go
        theDistanceSlider.addTarget(self, action: #selector(DistanceSliderView.valueChanged(_:)), forControlEvents: .ValueChanged)
        self.addSubview(theDistanceSlider)
        theDistanceSlider.snp_makeConstraints { (make) in
            make.trailing.leading.bottom.equalTo(self)
            make.top.equalTo(theDistanceLabel.snp_bottom).offset(10)
        }
    }
    
    func valueChanged(sender: UISlider) {
        let distanceValue = round(sender.value)
        if distanceValue >= 101 {
            theDistanceLabel.text = "100+ mi."
        } else {
            theDistanceLabel.text = "\(Int(distanceValue)) mi."
        }
    }
    
    func createDistanceLabel() {
        self.addSubview(theDistanceLabel)
        theDistanceLabel.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
        }
    }

}
