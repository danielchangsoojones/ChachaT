//
//  DistanceSliderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/23/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

protocol SingleSliderViewDelegate {
    func editSingleSliderChosenTagViewValue(value: Int, specialtyCategoryTitle: SpecialtyCategoryTitles)
    func createSingleSliderChosenTagView(sliderValue: Int, specialtyCategoryTitle: SpecialtyCategoryTitles)
}

class SingleSliderView: UIView {
    //TODO: probably need to make the height actually based on something
    let theSliderLabel = UILabel(frame: CGRectMake(0, 0, 0, 20))
    let theSlider = UISlider()
    let sliderOffsetFromLabel : CGFloat = 5
    private var sliderType : SpecialtyCategoryTitles?
    private var valueSuffix : String = ""
    
    private var delegate: SingleSliderViewDelegate?
    
    init() {
        super.init(frame: CGRectMake(0, 0, 0, theSliderLabel.frame.height + sliderOffsetFromLabel + theSlider.frame.height))
        createSliderLabel()
        createSlider()
    }
    
    init(maxValue: Int, suffix: String, delegate: SingleSliderViewDelegate) {
        super.init(frame: CGRectMake(0, 0, 0, theSliderLabel.frame.height + sliderOffsetFromLabel + theSlider.frame.height))
        self.delegate = delegate
        createSliderLabel()
        createSlider()
    }
    
    //Purpose: pass something like Location and " mi"
    func setDelegateAndCreateTagView(delegate: SingleSliderViewDelegate, specialtyCategoryTitle: SpecialtyCategoryTitles, valueSuffix: String) {
        self.delegate = delegate
        self.sliderType = specialtyCategoryTitle
        self.valueSuffix = valueSuffix
        delegate.createSingleSliderChosenTagView(50, specialtyCategoryTitle: sliderType!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSlider() {
        theSlider.minimumTrackTintColor = ChachaTeal
        theSlider.maximumTrackTintColor = CustomColors.BombayGrey
        theSlider.maximumValue = 101
        theSlider.minimumValue = 1
        theSlider.thumbTintColor = CustomColors.BombayGrey
        theSlider.continuous = true // false makes it call only once you let go
        theSlider.addTarget(self, action: #selector(SingleSliderView.valueChanged(_:)), forControlEvents: .ValueChanged)
        self.addSubview(theSlider)
        theSlider.snp_makeConstraints { (make) in
            make.trailing.leading.equalTo(self)
            make.bottom.equalTo(self)
            make.top.equalTo(theSliderLabel.snp_bottom).offset(sliderOffsetFromLabel)
        }
    }
    
    func valueChanged(sender: UISlider) {
        let sliderValue = round(sender.value)
        if sliderValue >= 101 {
            theSliderLabel.text = "100+ mi."
        } else {
            theSliderLabel.text = "\(Int(sliderValue)) mi."
        }
        delegate?.editSingleSliderChosenTagViewValue(Int(sliderValue), specialtyCategoryTitle: sliderType!)
    }
    
    func createSliderLabel() {
        self.addSubview(theSliderLabel)
        theSliderLabel.textColor = UIColor.whiteColor()
        theSliderLabel.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
        }
    }
}

extension SearchTagsViewController: SingleSliderViewDelegate {
    func createSingleSliderChosenTagView(sliderValue: Int, specialtyCategoryTitle: SpecialtyCategoryTitles) {
        if theSpecialtyChosenTagDictionary[specialtyCategoryTitle] == nil {
            //the tagview doesn't exist
            switch specialtyCategoryTitle {
            case .Location:
                //only want to create new tag if the tag doesn't already exist
                let tagTitle = "\(sliderValue) mi"
                let newTagView = tagChosenView.addTag(tagTitle)
                theSpecialtyChosenTagDictionary[specialtyCategoryTitle] = newTagView
                scrollViewSearchView.hideScrollSearchView(false)
                scrollViewSearchView.rearrangeSearchArea(newTagView, extend: true)
            default: break
            }
        }
    }
    
    func editSingleSliderChosenTagViewValue(sliderValue: Int, specialtyCategoryTitle: SpecialtyCategoryTitles) {
        let tagTitle = "\(sliderValue) mi"
        if let chosenTagView = theSpecialtyChosenTagDictionary[specialtyCategoryTitle] {
            tagChosenView.setTagViewTitle(chosenTagView!, title: tagTitle)
        }
    }
}
