//
//  SliderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/19/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import TTRangeSlider

protocol SliderViewDelegate {
    func sliderValueChanged(text: String)
    func sliderCreated(text: String)
}

class SliderView: UIView {
    private struct SliderViewConstants {
        static let sliderLabelTextColor = CustomColors.JellyTeal
        static let minValue : Int = 1
    }
    
    //TODO: add some of these constants to the struct
    let theSliderLabel = UILabel(frame: CGRectMake(0, 0, 0, 20))
    var theSlider = UIView()
    let sliderOffsetFromLabel : CGFloat = 5
    var suffix : String = ""
    var maxValue : Int = 0
    var minValue : Int = SliderViewConstants.minValue
    
    var delegate: SliderViewDelegate?
    
    init(maxValue: Int, minValue : Int = SliderViewConstants.minValue, suffix: String, isRangeSlider: Bool, delegate: SliderViewDelegate) {
//        super.init(frame: CGRectMake(0, 0, 0, theSliderLabel.frame.height + sliderOffsetFromLabel + theSlider.frame.height))
        super.init(frame: CGRectZero)
//        super.init(frame: CGRect(x: 0, y: 0, w: 0, h: 100))
        self.delegate = delegate
        self.suffix = suffix
        self.maxValue = maxValue
        self.minValue = minValue
        createSliderLabel()
        addSliderToView(isRangeSlider)
        //TODO: make this all come from intrinsic contentSize, and then we can just set those in all of our methods. 
        self.frame = CGRect(x: 0, y: 0, w: 0, h: theSliderLabel.frame.height + sliderOffsetFromLabel + theSlider.intrinsicContentSize().height) //this makes the frame calculatable, so we can calculate the height for other views
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSliderLabel() {
        self.addSubview(theSliderLabel)
        theSliderLabel.textColor = SliderViewConstants.sliderLabelTextColor
        theSliderLabel.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
        }
    }
    
    func addSliderToView(isRangeSlider: Bool) {
        var sliderText = ""
        if isRangeSlider {
            self.theSlider = createRangeSlider(self.minValue, maxValue: self.maxValue)
            sliderText = setRangeSliderLabelText(self.minValue, maxValue: self.maxValue)
        } else {
            self.theSlider = createSingleSlider(self.maxValue)
            sliderText = setSingleSliderLabelText(self.maxValue)
        }
        self.addSubview(theSlider)
        theSlider.snp_makeConstraints { (make) in
            make.trailing.leading.equalTo(self)
            make.bottom.equalTo(self)
            make.top.equalTo(theSliderLabel.snp_bottom).offset(sliderOffsetFromLabel)
        }
        delegate?.sliderCreated(sliderText)
    }
}

//for the Single Slider
extension SliderView {
    func createSingleSlider(maxValue: Int) -> UISlider {
        let slider = UISlider()
        slider.minimumTrackTintColor = ChachaTeal
        slider.maximumTrackTintColor = CustomColors.BombayGrey
        slider.maximumValue = maxValue.toFloat
        slider.minimumValue = 1
        slider.thumbTintColor = CustomColors.BombayGrey
        slider.continuous = true // false makes it call only once you let go
        slider.addTarget(self, action: #selector(SingleSliderView.valueChanged(_:)), forControlEvents: .ValueChanged)
        return slider
    }
    
    func valueChanged(sender: UISlider) {
        let sliderValue = round(sender.value)
        let text = setSingleSliderLabelText(Int(sliderValue))
        delegate?.sliderValueChanged(text)
    }
    
    func setSingleSliderLabelText(num: Int) -> String {
        var text = ""
        if num >= self.maxValue {
            text += "\(num)+" //creates something like 100+, when you are at the max value
        } else {
            text += num.toString
        }
        text = addSuffix(text, suffix: suffix)
        theSliderLabel.text = text
        return text
    }
    
    func addSuffix(text: String, suffix: String) -> String {
        return text + " " + suffix
    }
}

extension SliderView : TTRangeSliderDelegate {
    func createRangeSlider(minValue: Int, maxValue: Int) -> TTRangeSlider {
        let rangeSlider = TTRangeSlider()
        rangeSlider.delegate = self
        rangeSlider.maxValue = maxValue.toFloat
        rangeSlider.minValue = minValue.toFloat
        rangeSlider.selectedMaximum = maxValue.toFloat
        rangeSlider.selectedMinimum = minValue.toFloat
        rangeSlider.maxLabelColour = ChachaTeal
        rangeSlider.minLabelColour = ChachaTeal
        rangeSlider.minDistance = 0
        rangeSlider.tintColor = CustomColors.BombayGrey
        rangeSlider.tintColorBetweenHandles = ChachaTeal
        rangeSlider.handleDiameter = 27
        rangeSlider.selectedHandleDiameterMultiplier = 1.2
        return rangeSlider
    }
    
    func setRangeSliderLabelText(minValue: Int, maxValue: Int) -> String {
        var text = ""
        let minValueText = addSuffix(minValue.toString, suffix: suffix)
        text += minValueText + " - "
        if maxValue >= self.maxValue {
            text += addSuffix("\(maxValue)+", suffix: suffix) //creates something like 100+ mi, when you are at the max value
        } else {
            text += addSuffix(maxValue.toString, suffix: suffix)
        }
        theSliderLabel.text = text
        return text
    }
    
    func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        let text = setRangeSliderLabelText(Int(selectedMinimum), maxValue: Int(selectedMaximum))
        delegate?.sliderValueChanged(text)
    }
}
