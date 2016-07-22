//
//  StackViewButtonsController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/22/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

protocol StackViewTagButtonsDelegate {
    func createChosenTag(tagTitle: String)
    func removeChosenTag(tagTitle: String)
    func doesChosenTagViewContain(tagTitle: String) -> Bool
    func removeChoicesTag(tagTitle: String)
    func editSpecialtyTagView(newTagTitle: String, originalTagTitle: String, filterNameCategory: SpecialtyTags)
}

class StackViewTagButtons: UIStackView {
    
    var delegate: StackViewTagButtonsDelegate?
    let noneButtonText = "None"
    var pushOneButton = false
    var buttonArray: [UIButton] = []
    var originalTagTitle : String = "?"
    var filterCategory : String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackViewProperties()
    }
    
    init(filterCategory: String, addNoneButton: Bool, delegate: StackViewTagButtonsDelegate, pushOneButton: Bool) {
        super.init(frame: CGRectMake(0, 0, 200, 200))
        self.filterCategory = filterCategory
        setStackViewProperties()
        self.delegate = delegate
        self.addButtonsToStackView(filterCategory, addNoneButton: addNoneButton)
        self.pushOneButton = pushOneButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStackViewProperties() {
        self.axis = .Horizontal
        self.alignment = .Fill
        self.distribution = .FillEqually
        self.spacing = 2
    }
    
    func addButtonsToStackView(filterCategory: String, addNoneButton: Bool) {
        switch filterCategory {
        case SpecialtyTags.Race.rawValue:
            iterateThroughFilterNames(FilterNames.raceAllValues, addNoneButton: addNoneButton)
        case SpecialtyTags.Gender.rawValue:
            iterateThroughFilterNames(FilterNames.genderAllValues, addNoneButton: addNoneButton)
        case SpecialtyTags.HairColor.rawValue:
            iterateThroughFilterNames(FilterNames.hairColorAllValues, addNoneButton: addNoneButton)
        case SpecialtyTags.Sexuality.rawValue:
            iterateThroughFilterNames(FilterNames.sexualityAllValues, addNoneButton: addNoneButton)
        case SpecialtyTags.PoliticalAffiliation.rawValue:
            iterateThroughFilterNames(FilterNames.politicalAffiliationAllValues, addNoneButton: addNoneButton)
        default:
            break
        }
    }
    
    func iterateThroughFilterNames(filterNamesArray: [FilterNames], addNoneButton: Bool) {
        for filterName in filterNamesArray {
            if filterName != FilterNames.NoneFilter || addNoneButton {
                //this lets all buttons be made except for none buttton. If addnonebutton is true, then it will allow a none button to be made
                let button = createButton(filterName)
                buttonArray.append(button)
                self.addArrangedSubview(button)
            }
        }
    }
    
    func createButton(filterName: FilterNames) -> UIButton {
        let button: UIButton = {
            $0.setTitle(filterName.rawValue, forState: .Normal)
            let tagHasNotBeenChosen = !(delegate?.doesChosenTagViewContain(filterName.rawValue))!
            if !tagHasNotBeenChosen {
                //this button title was the original text for the tag that we were passed. So, we want to save, so we know what to pass later to the delegate
                originalTagTitle = filterName.rawValue
            }
            changeButtonHighlight(tagHasNotBeenChosen, button: $0, changeChosenTags: false, changeChoicesTag: false)
            $0.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
            $0.layer.cornerRadius = 10
            return $0
        }(UIButton())
        
        return button
    }
    
    func buttonTapped(sender: UIButton!) {
        let buttonHighlighted : Bool = (sender.backgroundColor == ChachaTeal)
        if pushOneButton && !buttonHighlighted {
            chooseOneButton(sender, buttonArray: buttonArray)
        } else {
            changeButtonHighlight(buttonHighlighted, button: sender, changeChosenTags: true, changeChoicesTag: true)
            if let buttonTitle = sender.titleLabel?.text {
                 delegate?.createChosenTag(buttonTitle)
            }
        }
    }
    
    func changeButtonHighlight(buttonHighlighted: Bool, button: UIButton, changeChosenTags: Bool, changeChoicesTag: Bool) {
        if buttonHighlighted {
                    //we are unhighlighting the button
                    button.backgroundColor = ChachaBombayGrey
                    button.setTitleColor(ChachaTeal, forState: .Normal)
                } else {
                    //highlight the button
                    button.backgroundColor = ChachaTeal
                    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }
    }
    
    //you can only push one button when inputing your characteristics
    func chooseOneButton (pushedButton: UIButton, buttonArray: [UIButton]) {
        for button in buttonArray {
            if button == pushedButton {
                //set the pushed button to highlighted
                changeButtonHighlight(false, button: pushedButton, changeChosenTags: true, changeChoicesTag: true)
//                if let filterNameCategory = findFilterNameCategory(button.titleLabel!.text!) {
                if let filterCategory = SpecialtyTags(rawValue: filterCategory) {
                    delegate?.editSpecialtyTagView((button.titleLabel?.text)!, originalTagTitle: originalTagTitle, filterNameCategory: filterCategory)
                }
//                }
            } else {
                //set the non-pushed buttons all to unhighlighted
                changeButtonHighlight(true, button: button, changeChosenTags: true, changeChoicesTag: true)
            }
        }
    }

    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}
