//
//  SpecialtyTagEnviromentHolderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

class SpecialtyTagEnviromentHolderView: UIView {
    
    var theSpecialtyView: UIView?
    let theDoneButton: UIButton = {
        $0.setTitle("Done", forState: .Normal)
        return $0
    }(UIButton())
    let theTitleLabel: UILabel = {
        return $0
    }(UILabel())
    let theStackView: UIStackView = {
        $0.alignment = .Center
        $0.axis = .Vertical
        $0.distribution = .EqualCentering
        return $0
    }(UIStackView())
    
    func doneButtonTapped(sender: UIButton!) {
        print("done button tapped")
    }
    
    init(specialtyView: UIView) {
        super.init(frame: CGRectMake(0, 0, 200, 200))
        self.theSpecialtyView = specialtyView
        self.backgroundColor = UIColor.redColor()
        createStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createStackView() {
        self.addSubview(theStackView)
        theStackView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addItemsToStackView()
    }
    
    func addItemsToStackView() {
        theStackView.addArrangedSubview(theTitleLabel)
        if let theSpecialtyView = theSpecialtyView {
            theStackView.addArrangedSubview(theSpecialtyView)
        }
        theStackView.addArrangedSubview(theDoneButton)
        theDoneButton.addTarget(self, action: #selector(doneButtonTapped), forControlEvents: .TouchUpInside)
    }
    
    func createDistanceSliderView() {
        //the frame gets overrided by the snp_constraints
        let theDistanceSliderView = DistanceSliderView()
        //had to set the initial value for the slider here because not loading when I put in the slider view class
        theDistanceSliderView.theDistanceSlider.setValue(50.0, animated: false)
    }
    
    func createAgeRangeSliderView() {
        theAgeRangeSliderView = AgeDoubleRangeSliderView(frame: CGRectMake(0, 0, 200, 200))
        theSpecialtyTagEnviromentHolderView.addSubview(theAgeRangeSliderView!)
        theAgeRangeSliderView?.snp_makeConstraints(closure: { (make) in
            make.leading.equalTo(theSpecialtyTagEnviromentHolderView).offset(8)
            make.trailing.equalTo(theSpecialtyTagEnviromentHolderView).offset(-8)
            make.top.equalTo(theCategoryLabel).offset(100)
            make.height.equalTo(30)
        })
    }

}
