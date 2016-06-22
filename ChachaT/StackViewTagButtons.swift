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
}

class StackViewTagButtons: UIStackView {
    
    enum FilterCategories : String {
        case Race = "race"
        case HairColor = "hairColor"
        case PoliticalAffiliation = "politicalAffiliation"
        case Sexuality = "sexuality"
        case Gender = "gender"
    }
    
    enum FilterNames : String {
        case RaceBlackFilter = "black"
        case RaceWhiteFilter = "white"
        case RaceLatinoFilter = "latino"
        case RaceAsianFilter = "asian"
        case HairColorBrunetteFilter = "brunette"
        case HairColorBlondeFilter = "blonde"
        case HairColorRedheadFilter = "redhead"
        case PoliticalAffiliationDemocratFilter = "democrat"
        case PoliticalAffiliationRepublicanFilter = "republican"
        case GenderMaleFilter = "male"
        case GenderFemaleFilter = "female"
        case SexualityStraightFilter = "straight"
        case SexualityGayFilter = "gay"
        case SexualityBisexualFilter = "bisexual"
        
        //this array lets me iterate over certain sections of the enum
        static let raceAllValues = [RaceBlackFilter, RaceWhiteFilter, RaceLatinoFilter, RaceAsianFilter]
        static let hairColorAllValues = [HairColorBrunetteFilter, HairColorBlondeFilter, HairColorRedheadFilter]
        static var genderAllValues = [GenderMaleFilter, GenderFemaleFilter]
        static let sexualityAllValues = [SexualityStraightFilter, SexualityGayFilter, SexualityBisexualFilter]
        static let politicalAffiliationAllValues = [PoliticalAffiliationDemocratFilter, PoliticalAffiliationRepublicanFilter]
    }
    
    var filterCategory: FilterCategories = .Race
    var delegate: StackViewTagButtonsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackViewProperties()
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
    
    func addButtonToStackView(filterCategory: FilterCategories) {
        switch filterCategory {
        case .Race:
            iterateThroughFilterNames(FilterNames.raceAllValues)
        case .Gender:
            iterateThroughFilterNames(FilterNames.genderAllValues)
        case .HairColor:
            iterateThroughFilterNames(FilterNames.hairColorAllValues)
        case .Sexuality:
            iterateThroughFilterNames(FilterNames.sexualityAllValues)
        case .PoliticalAffiliation:
            iterateThroughFilterNames(FilterNames.politicalAffiliationAllValues)
        }
    }
    
    func iterateThroughFilterNames(filterNamesArray: [FilterNames]) {
        for filterName in filterNamesArray {
            let button = createButton()
            button.setTitle(filterName.rawValue, forState: .Normal)
            self.addArrangedSubview(button)
        }
    }
    
    func createButton() -> UIButton {
        let button: UIButton = {
            $0.backgroundColor = ChachaBombayGrey
            $0.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
            $0.layer.cornerRadius = 10
            $0.setTitleColor(ChachaTeal, forState: .Normal)
            return $0
        }(UIButton())
        
        return button
    }
    
    func buttonTapped(sender: UIButton!) {
        let buttonHighlighted : Bool = (sender.backgroundColor == ChachaTeal)
        if buttonHighlighted {
            //we are unhighlighting it and remove the tag from the Tag Chosen View
            sender.backgroundColor = ChachaBombayGrey
            sender.setTitleColor(ChachaTeal, forState: .Normal)
            delegate!.removeChosenTag((sender.titleLabel?.text)!)
        } else {
            //we highlight it
            sender.backgroundColor = ChachaTeal
            sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            delegate?.createChosenTag((sender.titleLabel?.text)!)
        }
    }

}
