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
}
