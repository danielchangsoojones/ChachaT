//
//  SpecialtyTagEnviromentHolderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

public enum SpecialtyTagEnviroments {
    case DistanceSlider
    case AgeRangeSlider
    case StackViewButtons
    case CreateNewTag
}

class SpecialtyTagEnviromentHolderView: UIView {
    
    var theSpecialtyView: UIView?
    let theDoneButton: UIButton = {
        $0.setTitleColor(UIColor.blueColor(), forState: .Normal)
        $0.setTitle("Done", forState: .Normal)
        return $0
    }(UIButton())
    let theTitleLabel: UILabel = {
        $0.textColor = UIColor.blackColor()
        return $0
    }(UILabel())
    let theStackView: UIStackView = {
        $0.alignment = .Center
        $0.axis = .Vertical
        $0.distribution = .EqualSpacing
        return $0
    }(UIStackView())
    
    func doneButtonTapped(sender: UIButton!) {
        print("done button tapped")
    }
    
    init(specialtyTagEnviroment: SpecialtyTagEnviroments) {
        super.init(frame: CGRectMake(0, 0, 200, 200))
        switch specialtyTagEnviroment {
        case .DistanceSlider:
            createDistanceSliderView()
        case .AgeRangeSlider:
            theSpecialtyView = AgeDoubleRangeSliderView()
        case .StackViewButtons:
            break
        case .CreateNewTag:
            break
        }
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
            theSpecialtyView.snp_makeConstraints(closure: { (make) in
                make.width.equalTo(40)
                make.height.equalTo(30)
            })
        }
        theStackView.addArrangedSubview(theDoneButton)
        theDoneButton.addTarget(self, action: #selector(doneButtonTapped), forControlEvents: .TouchUpInside)
    }
    
    func createDistanceSliderView() {
        let theDistanceSliderView = DistanceSliderView()
        //had to set the initial value for the slider here because not loading when I put in the slider view class
        theDistanceSliderView.theDistanceSlider.setValue(50.0, animated: false)
        theSpecialtyView = theDistanceSliderView
    }
}
