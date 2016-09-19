//
//  SliderDropDown.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

//This extension is for dealing with sliders in the dropDownMenu
extension ChachaDropDownMenu {
    func addSlider(isRangeSlider: Bool, sliderDelegate: SliderViewDelegate) {
        var sliderView : SliderView!
        if isRangeSlider {
            sliderView = SliderView(maxValue: 100, minValue: 10, suffix: "pi", isRangeSlider: true, delegate: sliderDelegate)
        } else {
            //a single slider
            sliderView = SliderView(maxValue: 40, suffix: "ty", isRangeSlider: false, delegate: sliderDelegate)
        }
        self.innerView = sliderView
        addInnerView()
        self.show()
    }
    
//    func showSingleSliderView() {
//        dropDownMenuType = .SpecialtySingleSlider
//        self.singleSliderView = addSingleSliderViewToView(dropDownView)
//        self.showMenu()
//    }
//    
//    func addSingleSliderViewToView(view: UIView) -> SingleSliderView {
//            let theSliderView = SingleSliderView()
//            let sliderIntitalValue = theSliderView.theSlider.maximumValue / 2
//            theSliderView.theSlider.setValue(sliderIntitalValue, animated: false) //I have to set the initial value here, can't set in actual class for some reason
//            theSliderView.theSliderLabel.text =  "\(Int(sliderIntitalValue)) mi."
//            view.addSubview(theSliderView)
//            theSliderView.snp_makeConstraints { (make) in
//                make.trailing.equalTo(view).inset(10)
//                make.leading.equalTo(view).offset(10)
//                //using low priority because the compiler needs to know which constraints to break when the dropDownHeight is 0
//                make.bottom.equalTo(arrowImage.snp_top).offset(-arrowImageInset).priorityLow() //not sure why inset(5) does not work, but it doesn't
//            }
//            return theSliderView
//    }
}
