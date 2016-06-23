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
    let distanceLabel = UILabel()
    let distanceSlider = UISlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createDistanceSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createDistanceSlider() {
        distanceSlider.minimumTrackTintColor = ChachaTeal
        distanceSlider.maximumTrackTintColor = UIColor.whiteColor()
        distanceSlider.maximumValue = 101
        distanceSlider.minimumValue = 1
        distanceSlider.thumbTintColor = UIColor.whiteColor()
        distanceSlider.continuous = true // false makes it call only once you let go
        distanceSlider.addTarget(self, action: #selector(DistanceSliderView.valueChanged(_:)), forControlEvents: .ValueChanged)
        self.addSubview(distanceSlider)
        distanceSlider.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func valueChanged(sender: UISlider) {
        let distanceValue = round(sender.value)
//        if distanceValue >= 101 {
//            theDistanceMilesLabel.text = "100+ mi."
//        } else {
//            theDistanceMilesLabel.text = "\(Int(distanceValue)) mi."
//        }
    }
    
    func createDistanceLabel() {
        self.addSubview(distanceLabel)
        distanceLabel.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }

}
