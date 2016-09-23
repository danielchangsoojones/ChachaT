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
    func sliderValueChanged(_ text: String, suffix: String)
}

class SliderView: UIView {
    fileprivate struct SliderViewConstants {
        static let sliderLabelTextColor = CustomColors.JellyTeal
        static let minValue : Int = 1
        static let sliderOffsetFromLabel : CGFloat = 5
        static let selectedTrackColor : UIColor = CustomColors.JellyTeal
        static let nonSelectedTrackColor : UIColor = CustomColors.BombayGrey
    }
    
    //TODO: add some of these constants to the struct
    let theSliderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
    var theSlider = UIView()
    var suffix : String = ""
    var maxValue : Int = 0
    var minValue : Int = SliderViewConstants.minValue
    
    var delegate: SliderViewDelegate?
    
    init(maxValue: Int, minValue : Int = SliderViewConstants.minValue, suffix: String, isRangeSlider: Bool, delegate: SliderViewDelegate) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        self.suffix = suffix
        self.maxValue = maxValue
        self.minValue = minValue
        createSliderLabel()
        addSliderToView(isRangeSlider)
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
    
    func addSliderToView(_ isRangeSlider: Bool) {
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
            make.top.equalTo(theSliderLabel.snp_bottom).offset(SliderViewConstants.sliderOffsetFromLabel)
        }
        delegate?.sliderValueChanged(sliderText, suffix: suffix)
    }
    
    override var intrinsicContentSize : CGSize {
        let height = theSliderLabel.frame.height + SliderViewConstants.sliderOffsetFromLabel + theSlider.intrinsicContentSize.height
        let width : CGFloat = 0
        return CGSize(width: width, height: height)
    }
}

//for the Single Slider
extension SliderView {
    func createSingleSlider(_ maxValue: Int) -> UISlider {
        let slider = UISlider()
        slider.minimumTrackTintColor = SliderViewConstants.selectedTrackColor
        slider.maximumTrackTintColor = SliderViewConstants.nonSelectedTrackColor
        slider.maximumValue = maxValue.toFloat
        slider.minimumValue = SliderViewConstants.minValue.toFloat
        slider.thumbTintColor = SliderViewConstants.nonSelectedTrackColor
        slider.isContinuous = true // false makes it call only once you let go
        slider.addTarget(self, action: #selector(SliderView.valueChanged(_:)), for: .valueChanged)
        return slider
    }
    
    func valueChanged(_ sender: UISlider) {
        let sliderValue = round(sender.value)
        let text = setSingleSliderLabelText(Int(sliderValue))
        delegate?.sliderValueChanged(text, suffix: suffix)
    }
    
    func setSingleSliderLabelText(_ num: Int) -> String {
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
    
    func addSuffix(_ text: String, suffix: String) -> String {
        return text + " " + suffix
    }
}

extension SliderView : TTRangeSliderDelegate {
    func createRangeSlider(_ minValue: Int, maxValue: Int) -> TTRangeSlider {
        let rangeSlider = TTRangeSlider()
        rangeSlider.delegate = self
        rangeSlider.maxValue = maxValue.toFloat
        rangeSlider.minValue = minValue.toFloat
        rangeSlider.selectedMaximum = maxValue.toFloat
        rangeSlider.selectedMinimum = minValue.toFloat
        rangeSlider.maxLabelColour = SliderViewConstants.selectedTrackColor
        rangeSlider.minLabelColour = SliderViewConstants.selectedTrackColor
        rangeSlider.minDistance = 0
        rangeSlider.tintColor = SliderViewConstants.nonSelectedTrackColor
        rangeSlider.tintColorBetweenHandles = SliderViewConstants.selectedTrackColor
        rangeSlider.handleDiameter = 27
        rangeSlider.selectedHandleDiameterMultiplier = 1.2
        return rangeSlider
    }
    
    func setRangeSliderLabelText(_ minValue: Int, maxValue: Int) -> String {
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
    
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        let text = setRangeSliderLabelText(Int(selectedMinimum), maxValue: Int(selectedMaximum))
        delegate?.sliderValueChanged(text, suffix: suffix)
    }
}
