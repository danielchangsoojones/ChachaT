//
//  SearchTagsSliderExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/7/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

extension SearchTagsViewController {
    func transformSearchBarForSlider() {
        changeButtonAppearances()
        
        //we have to wait until the dropDownMenu is actually hidden, not just hiding, because the hit test on the search bar will say tapped as we tap the buttons, which will revert the button targets back to their original before the buttons even had a chance to perform the new actions
        NotificationCenter.default.addObserver(self, selector: #selector(revertToOriginalSearchBar), name: .dropDownMenuHidden, object: nil)
    }
    
    fileprivate func changeButtonAppearances() {
        toggleSearchMoreTagsButton(isSliderShown: true)
        let goButton = scrollViewSearchView.theGoButton
        let exitButton = scrollViewSearchView.theExitButton
        
        invertButton(isSliderShown: true, button: goButton ?? UIButton())
        invertButton(isSliderShown: true, button: exitButton ?? UIButton())
        
        setNewButtonAction(button: goButton!, selector: #selector(acceptSlider), target: self)
        setNewButtonAction(button: exitButton!, selector: #selector(cancelSlider), target: self)
    }
    
    fileprivate func setNewButtonAction(button: UIButton, selector: Selector, target: Any?) {
        //remove any previous targets of the button
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(target, action: selector, for: .allEvents)
    }
    
    fileprivate func toggleSearchMoreTagsButton(isSliderShown: Bool) {
        let searchMoreTagsButton = scrollViewSearchView.theSearchButton
        //for some reason, just hiding the button from the stack view is not enough. We have to physically remove it, then it only exists in the view, and then we hide it. When we want it back, we add it back to the stackView
        if isSliderShown {
            scrollViewSearchView.theButtonStackView.removeArrangedSubview(scrollViewSearchView.theSearchButton)
        } else {
            scrollViewSearchView.theButtonStackView.insertArrangedSubview(searchMoreTagsButton!, at: 0)
        }
        
        scrollViewSearchView.theSearchButton.isHidden = isSliderShown
    }
    
    fileprivate func invertButton(isSliderShown: Bool, button: UIButton) {
        button.backgroundColor = isSliderShown ? CustomColors.SilverChaliceGrey : UIColor.white
        button.layer.borderColor = isSliderShown ? UIColor.clear.cgColor : TagViewProperties.borderColor.cgColor
        setButtonImageColor(color: isSliderShown ? UIColor.white : TagViewProperties.borderColor, button: button)
    }
    
    fileprivate func setButtonImageColor(color: UIColor, button: UIButton) {
        let origImage = button.currentImage
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = color
    }
    
    @objc fileprivate func cancelSlider() {
        if let sliderView = dropDownMenu.innerView as? SliderView, let title = sliderView.theSliderLabel.text {
            let tagView = tagChosenView.tagViews.first(where: { (tagView: TagView) -> Bool in
                return tagView.currentTitle == title
            })
            if let tagView = tagView {
                chosenTags = chosenTags.filter({ (tag: Tag) -> Bool in
                    return tag.title != tagView.currentTitle ?? ""
                })
                tagChosenView.removeTagView(tagView)
                scrollViewSearchView?.rearrangeSearchArea(tagView, extend: false)
            }
        }
        dropDownMenu.hide()
    }
    
    @objc fileprivate func acceptSlider() {
        dropDownMenu.hide()
    }
    
    func revertToOriginalSearchBar() {
        NotificationCenter.default.removeObserver(self, name: .dropDownMenuHidden, object: nil)
        
        if dropDownMenu.innerView is SliderView {
            toggleSearchMoreTagsButton(isSliderShown: false)
            
            let goButton = scrollViewSearchView.theGoButton
            let exitButton = scrollViewSearchView.theExitButton
            
            //revert the image color back to its original form
            invertButton(isSliderShown: false, button: goButton!)
            invertButton(isSliderShown: false, button: exitButton!)
            
            //revert the targets back to their original 
            setNewButtonAction(button: goButton!, selector: #selector(ScrollViewSearchView.goButtonTapped(_:)), target: scrollViewSearchView)
            setNewButtonAction(button: exitButton!, selector: #selector(ScrollViewSearchView.exitButtonTapped(_:)), target: scrollViewSearchView)
            
            updateAfterTagChosen()
        }
    }
}


extension SearchTagsViewController: SliderViewDelegate {
    func sliderValueChanged(text: String, minValue: Int, maxValue: Int, suffix: String) {
        scrollViewSearchView.hideScrollSearchView(false)
        if let tagView = findTagViewWithSuffix(suffix) {
            //the tagView has already been created
            //TODO: make the sliderView scroll over to where the tag is because if it is off the screen, then the user can't see it.
            tagView.setTitle(text, for: UIControlState())
        } else {
            let tagView = tagChosenView.addTag(text)
            scrollViewSearchView?.rearrangeSearchArea(tagView, extend: true)
            scrollViewSearchView.hideScrollSearchView(false) //making the search bar disappear in favor of the scrolling area for the tagviews. like 8tracks does.
        }
    }
    
    func slidingEnded(text: String, minValue: Int, maxValue: Int, suffix: String) {
        //when they finish sliding, we want to add the dropDownTag as well as update the bottom user area.
        appendSliderTagToChosenTags(text: text, minValue: minValue, maxValue: maxValue, suffix: suffix)
        updateAfterTagChosen()
    }
    
    func sliderShown(text: String, minValue: Int, maxValue: Int, suffix: String) {
        //even if the slider is just shown, and then not touched, it still adds the tag to the dropDownTags
        appendSliderTagToChosenTags(text: text, minValue: minValue, maxValue: maxValue, suffix: suffix)
    }
    
    func appendSliderTagToChosenTags(text: String, minValue: Int, maxValue: Int, suffix: String) {
        if let dropDownTagView = tappedDropDownTagView {
            //check if the dropDownTag already exists in the chosenTags
            let tag: Tag? = chosenTags.first(where: { (tag: Tag) -> Bool in
                if let dropDownTag = tag as? DropDownTag {
                    return dropDownTag.specialtyCategory == dropDownTagView.specialtyCategoryTitle
                }
                return false
            })
            
            
            if let tag = tag as? DropDownTag {
                //if it already exists, we need to reset its title
                tag.title = text
                tag.maxValue = maxValue
                tag.minValue = minValue
            } else {
                let tag = DropDownTag(specialtyCategory: dropDownTagView.specialtyCategoryTitle, minValue: minValue, maxValue: maxValue, suffix: suffix, dropDownAttribute: .singleSlider)
                tag.title = text
                chosenTags.append(tag)
            }
        }
    }
    
    //TODO: change this to work with a regex that checks if the given tagViewTitle works with a particular pattern.
    func findTagViewWithSuffix(_ suffix: String) -> TagView? {
        for tagView in tagChosenView.tagViews {
            //TODO: should get the tagView, not just based upon the suffix. Should check that the text is exactly how we would structure a numbered tagView
            if let currentTitle = tagView.currentTitle , currentTitle.hasSuffix(suffix) {
                return tagView
            }
        }
        return nil
    }
}
