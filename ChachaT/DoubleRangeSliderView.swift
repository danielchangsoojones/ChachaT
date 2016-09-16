//
//  AgeDoubleRangeSliderView.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/23/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit
import TTRangeSlider

protocol DoubleRangeSliderViewDelegate {
    func editRangeSliderChosenTagViewValue(selectedMinValue: Int, selectedMaxValue: Int, specialtyCategoryTitle: SpecialtyCategoryTitles)
    func createRangeSliderChosenTagView(selectedMinValue: Int, selectedMaxValue: Int, specialtyCategoryTitle: SpecialtyCategoryTitles)
}

class DoubleRangeSliderView: UIView {
    let theDoubleRangeLabel = UILabel()
    let theDoubleRangeSlider = TTRangeSlider()
    var theSliderCategoryType: SpecialtyCategoryTitles!
    
    var delegate: DoubleRangeSliderViewDelegate?
    
    init(delegate: DoubleRangeSliderViewDelegate, sliderCategoryType: SpecialtyCategoryTitles) {
        super.init(frame: CGRectMake(0, 0, 0, theDoubleRangeSlider.intrinsicContentSize().height + 10)) //the height value sets the height of sliderview. It's pretty arbitrary right now, and coudl definetly be changed.
        self.theSliderCategoryType = sliderCategoryType
        self.delegate = delegate
        createDoubleRangeSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createDoubleRangeSlider() {
        let maxValue : Float = 65
        let minValue : Float = 18
        
        theDoubleRangeSlider.maxValue = maxValue
        theDoubleRangeSlider.minValue = minValue
        theDoubleRangeSlider.selectedMaximum = maxValue
        theDoubleRangeSlider.selectedMinimum = minValue
        theDoubleRangeSlider.maxLabelColour = ChachaTeal
        theDoubleRangeSlider.minLabelColour = ChachaTeal
        theDoubleRangeSlider.minDistance = 0
        theDoubleRangeSlider.tintColor = CustomColors.BombayGrey
        theDoubleRangeSlider.tintColorBetweenHandles = ChachaTeal
        theDoubleRangeSlider.handleDiameter = 27
        theDoubleRangeSlider.selectedHandleDiameterMultiplier = 1.2
        theDoubleRangeSlider.delegate = self
        delegate?.createRangeSliderChosenTagView(Int(minValue), selectedMaxValue: Int(maxValue), specialtyCategoryTitle: theSliderCategoryType)
        self.addSubview(theDoubleRangeSlider)
        theDoubleRangeSlider.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
}

extension DoubleRangeSliderView: TTRangeSliderDelegate {
    func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        delegate?.editRangeSliderChosenTagViewValue(Int(selectedMinimum), selectedMaxValue: Int(selectedMaximum), specialtyCategoryTitle: theSliderCategoryType)
    }
}

//Purpose: change the chosen tags of the filterQueryPage, so that it will update/create as the slider changes.
extension SearchTagsViewController: DoubleRangeSliderViewDelegate {
    func createRangeSliderChosenTagView(selectedMinValue: Int, selectedMaxValue: Int, specialtyCategoryTitle: SpecialtyCategoryTitles) {
        if theSpecialtyChosenTagDictionary[specialtyCategoryTitle] == nil {
            //the tagview doesn't exist
            switch specialtyCategoryTitle {
            case .AgeRange:
                //only want to create new tag if the tag doesn't already exist
                let tagTitle = "\(selectedMinValue) - \(selectedMaxValue)"
                let newTagView = tagChosenView.addTag(tagTitle)
                theSpecialtyChosenTagDictionary[specialtyCategoryTitle] = newTagView
                scrollViewSearchView.hideScrollSearchView(false)
                scrollViewSearchView.rearrangeSearchArea(newTagView, extend: true)
            default: break
            }
        }
    }
    
    func editRangeSliderChosenTagViewValue(selectedMinValue: Int, selectedMaxValue: Int, specialtyCategoryTitle: SpecialtyCategoryTitles) {
        let tagTitle = "\(selectedMinValue) - \(selectedMaxValue)"
        if let chosenTagView = theSpecialtyChosenTagDictionary[specialtyCategoryTitle] {
            tagChosenView.setTagViewTitle(chosenTagView!, title: tagTitle)
        }
    }
}
