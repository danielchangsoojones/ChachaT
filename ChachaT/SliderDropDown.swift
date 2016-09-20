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
    func addSlider(minValue: Int = 0, maxValue: Int, suffix: String, isRangeSlider: Bool, sliderDelegate: SliderViewDelegate) {
        var sliderView : SliderView!
        if isRangeSlider {
            sliderView = SliderView(maxValue: maxValue, minValue: minValue, suffix: suffix, isRangeSlider: true, delegate: sliderDelegate)
        } else {
            //a single slider
            sliderView = SliderView(maxValue: maxValue, suffix: suffix, isRangeSlider: false, delegate: sliderDelegate)
        }
        self.innerView = sliderView
        addInnerView()
        self.show()
    }
}
