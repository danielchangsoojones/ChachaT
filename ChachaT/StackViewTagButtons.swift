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
}

class StackViewTagButtons: UIStackView {
    
    var delegate: StackViewTagButtonsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackViewProperties()
    }
    
    init(filterCategory: String, addNoneButton: Bool, delegate: StackViewTagButtonsDelegate) {
        super.init(frame: CGRectMake(0, 0, 200, 200))
        setStackViewProperties()
        self.delegate = delegate
        self.addButtonsToStackView(filterCategory, addNoneButton: addNoneButton)
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
            iterateThroughFilterNames(FilterNames.raceAllValues)
        case SpecialtyTags.Gender.rawValue:
            iterateThroughFilterNames(FilterNames.genderAllValues)
        case SpecialtyTags.HairColor.rawValue:
            iterateThroughFilterNames(FilterNames.hairColorAllValues)
        case SpecialtyTags.Sexuality.rawValue:
            iterateThroughFilterNames(FilterNames.sexualityAllValues)
        case SpecialtyTags.PoliticalAffiliation.rawValue:
            iterateThroughFilterNames(FilterNames.politicalAffiliationAllValues)
        default:
            break
        }
        if addNoneButton {
            //if we are on editing tags for profile page, then the stack view should have a none button
            let button: UIButton = {
                changeButtonHighlight(true, button: $0, changeChosenTags: false)
                $0.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
                $0.layer.cornerRadius = 10
                $0.setTitle("None", forState: .Normal)
                return $0
            }(UIButton())
            self.addArrangedSubview(button)
        }
    }
    
    func iterateThroughFilterNames(filterNamesArray: [FilterNames]) {
        for filterName in filterNamesArray {
            let button = createButton(filterName)
            self.addArrangedSubview(button)
        }
    }
    
    func createButton(filterName: FilterNames) -> UIButton {
        let button: UIButton = {
            let tagHasNotBeenChosen = !(delegate?.doesChosenTagViewContain(filterName.rawValue))!
            changeButtonHighlight(tagHasNotBeenChosen, button: $0, changeChosenTags: false)
            $0.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
            $0.layer.cornerRadius = 10
            $0.setTitle(filterName.rawValue, forState: .Normal)
            return $0
        }(UIButton())
        
        return button
    }
    
    func buttonTapped(sender: UIButton!) {
        let buttonHighlighted : Bool = (sender.backgroundColor == ChachaTeal)
        changeButtonHighlight(buttonHighlighted, button: sender, changeChosenTags: true)
    }
    
    func changeButtonHighlight(buttonHighlighted: Bool, button: UIButton, changeChosenTags: Bool) {
        if buttonHighlighted {
            //we are unhighlighting the button
            button.backgroundColor = ChachaBombayGrey
            button.setTitleColor(ChachaTeal, forState: .Normal)
            if changeChosenTags {
                if let titleLabel = button.titleLabel {
                    if let tagTitle = titleLabel.text {
                        delegate!.removeChosenTag(titleLabel.text!)
                    }
                }
            }
        } else {
            //highlight the button
            button.backgroundColor = ChachaTeal
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            if changeChosenTags {
                if let titleLabel = button.titleLabel {
                    if let tagTitle = titleLabel.text {
                        delegate?.createChosenTag(tagTitle)
                    }
                }
            }
        }
    }

    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}
