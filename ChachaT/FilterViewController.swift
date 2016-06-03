//
//  FilterViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/1/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import TTRangeSlider
import Parse
import CoreLocation

class FilterViewController: UIViewController {
    
    @IBOutlet weak var theRaceAsianButton: UIButton!
    @IBOutlet weak var theRaceBlackButton: UIButton!
    @IBOutlet weak var theRaceLatinoButton: UIButton!
    @IBOutlet weak var theRaceWhiteButton: UIButton!
    @IBOutlet weak var theRaceAllButton: UIButton!
    @IBOutlet weak var theRaceStackView: UIStackView!
    @IBOutlet weak var theContentView: UIView!
    @IBOutlet weak var theRaceHolderView: UIView!
    @IBOutlet weak var theDistanceSlider: UISlider!
    @IBOutlet weak var theDistanceMilesLabel: UILabel!
    @IBOutlet weak var theDistanceGraySliderView: UIView!
    @IBOutlet weak var theAgeRangeSlider: TTRangeSlider!
    @IBOutlet weak var theAgeRangeLabel: UILabel!
    @IBOutlet weak var theHairColorBrunetteButton: UIButton!
    @IBOutlet weak var theHairColorRedheadButton: UIButton!
    @IBOutlet weak var theHairColorBlondeButton: UIButton!
    @IBOutlet weak var theHairColorAllButton: UIButton!
    @IBOutlet weak var theHairColorStackView: UIStackView!
    @IBOutlet weak var theHairColorHolderView: UIView!
    @IBOutlet weak var theSexualityStraightButton: UIButton!
    @IBOutlet weak var theSexualityGayButton: UIButton!
    @IBOutlet weak var theSexualityBisexualButton: UIButton!
    @IBOutlet weak var theSexualityAllButton: UIButton!
    @IBOutlet weak var thePoliticDemocratButton: UIButton!
    @IBOutlet weak var thePoliticRepublicanButton: UIButton!
    @IBOutlet weak var thePoliticAllButton: UIButton!
    @IBOutlet weak var theGenderMaleButton: UIButton!
    @IBOutlet weak var theGenderFemaleButton: UIButton!
    @IBOutlet weak var theGenderAllButton: UIButton!
    
    let cornerSize : CGFloat = 10
    var currentUserLocation : PFGeoPoint? = User.currentUser()?.location
    let currentUser = User.currentUser()
    
    var filterDictionary = [FilterNames : (filterState: Bool, filterCategory: FilterCategories)]()
    
    var delegate: FilterViewControllerDelegate?
    
    
    enum FilterNames : String {
        case RaceBlackFilter = "black"
        case RaceWhiteFilter = "white"
        case RaceLatinoFilter = "latino"
        case RaceAsianFilter = "asian"
        case RaceAllFilter
        case HairColorBrunetteFilter = "brunette"
        case HairColorBlondeFilter = "blonde"
        case HairColorRedheadFilter = "redhead"
        case HairColorAllFilter
        case PoliticalAffiliationDemocratFilter = "democrat"
        case PoliticalAffiliationRepublicanFilter = "republican"
        case PoliticalAffiliationAllFilter
        case GenderMaleFilter = "male"
        case GenderFemaleFilter = "female"
        case GenderAllFilter
        case SexualityStraightFilter = "straight"
        case SexualityGayFilter = "gay"
        case SexualityBisexualFilter = "bisexual"
        case SexualityAllFilter
        
        //this array lets me iterate over certain sections of the enum
        static let raceMinusAllValues = [RaceBlackFilter, RaceWhiteFilter, RaceLatinoFilter, RaceAsianFilter]
        static let hairColorMinusAllValues = [HairColorBrunetteFilter, HairColorBlondeFilter, HairColorRedheadFilter]
        static let genderMinusAllValues = [GenderMaleFilter, GenderFemaleFilter]
        static let sexualityMinusAllValues = [SexualityStraightFilter, SexualityGayFilter, SexualityBisexualFilter]
        static let politicalAffiliationMinusAllValues = [PoliticalAffiliationDemocratFilter, PoliticalAffiliationRepublicanFilter]
        static let theAllButtonValues = [RaceAllFilter, HairColorAllFilter, GenderAllFilter, SexualityAllFilter, PoliticalAffiliationAllFilter]
    }
    
    //for the whereKey queries to find the correct column name in parse
    enum FilterCategories : String {
        case RaceCategoryName = "race"
        case HairColorCategoryName = "hairColor"
        case PoliticalAffiliationCategoryName = "politicalAffiliation"
        case SexualityCategoryName = "sexuality"
        case GenderCategoryName = "gender"
        case locationCategoryName = "location"
        case ageCategoryName = "birthDate"
    }
    
    //the button pressed actions
    @IBAction func asianRaceButtonPressed(sender: UIButton) {
        let filterName = FilterNames.RaceAsianFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func blackRaceButtonPressed(sender: UIButton) {
        let filterName = FilterNames.RaceBlackFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func latinoRaceButtonPressed(sender: UIButton) {
        let filterName = FilterNames.RaceLatinoFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func whiteRaceButtonPressed(sender: UIButton) {
        let filterName = FilterNames.RaceWhiteFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func allRaceButtonPressed(sender: UIButton) {
        let filterName = FilterNames.RaceAllFilter
        filterButtonPressed(sender, filterName: filterName)
    }

    @IBAction func brunetteHairColorButtonPressed(sender: UIButton) {
        let filterName = FilterNames.HairColorBrunetteFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func redheadHairColorButtonPressed(sender: UIButton) {
        let filterName = FilterNames.HairColorRedheadFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func blondeHairColorButtonPressed(sender: UIButton) {
        let filterName = FilterNames.HairColorBlondeFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func allHairColorButtonPressed(sender: UIButton) {
        let filterName = FilterNames.HairColorAllFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func democratPoliticsButtonPressed(sender: UIButton) {
        let filterName = FilterNames.PoliticalAffiliationDemocratFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func republicanPoliticsButtonPressed(sender: UIButton) {
        let filterName = FilterNames.PoliticalAffiliationRepublicanFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func allPoliticsButtonPressed(sender: UIButton) {
        let filterName = FilterNames.PoliticalAffiliationAllFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func maleGenderButtonPressed(sender: UIButton) {
        let filterName = FilterNames.GenderMaleFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func femaleGenderButtonPressed(sender: UIButton) {
        let filterName = FilterNames.GenderFemaleFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func allGenderButtonPressed(sender: UIButton) {
        let filterName = FilterNames.GenderAllFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func straightSexualityButtonPressed(sender: UIButton) {
        let filterName = FilterNames.SexualityStraightFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func gaySexualityButtonPressed(sender: UIButton) {
        let filterName = FilterNames.SexualityGayFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func bisexualButtonPressed(sender: UIButton) {
        let filterName = FilterNames.SexualityBisexualFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    @IBAction func allSexualityButtonPressed(sender: UIButton) {
        let filterName = FilterNames.SexualityAllFilter
        filterButtonPressed(sender, filterName: filterName)
    }
    
    
    func filterButtonPressed(button: UIButton, filterName: FilterNames) {
        if let filterDictionaryCurrentState = filterDictionary[filterName]?.filterState {
            let filterDictionaryCurrentFilterCategory = filterDictionary[filterName]?.filterCategory
            filterDictionary.updateValue((filterState: !filterDictionaryCurrentState, filterCategory:filterDictionaryCurrentFilterCategory!), forKey: filterName)
            changeButtonBackground(button, currentState: filterDictionaryCurrentState)
            if !filterDictionaryCurrentState {
                //button should become highlighted and the all button should be unhighlighted
                //or if it is the all button, then all the other buttons should be dehighligheted/their state changed
                switch filterDictionaryCurrentFilterCategory {
                case .RaceCategoryName?:
                    let buttonMinusAllButtonArray : [UIButton] = [theRaceAsianButton, theRaceBlackButton, theRaceWhiteButton, theRaceLatinoButton]
                    changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: buttonMinusAllButtonArray, categoryArray: FilterNames.raceMinusAllValues, theAllButton: theRaceAllButton, theAllFilter: .RaceAllFilter)
                case .HairColorCategoryName?:
                    let buttonMinusAllButtonArray : [UIButton] = [theHairColorBrunetteButton, theHairColorRedheadButton, theHairColorBlondeButton]
                    changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: buttonMinusAllButtonArray, categoryArray: FilterNames.hairColorMinusAllValues, theAllButton: theHairColorAllButton, theAllFilter: .HairColorAllFilter)
                case .PoliticalAffiliationCategoryName?:
                    let buttonMinusAllButtonArray : [UIButton] = [thePoliticDemocratButton, thePoliticRepublicanButton]
                    changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: buttonMinusAllButtonArray, categoryArray: FilterNames.politicalAffiliationMinusAllValues, theAllButton: thePoliticAllButton, theAllFilter: .PoliticalAffiliationAllFilter)
                case .GenderCategoryName?:
                    let buttonMinusAllButtonArray : [UIButton] = [theGenderMaleButton, theGenderFemaleButton]
                    changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: buttonMinusAllButtonArray, categoryArray: FilterNames.genderMinusAllValues, theAllButton: theGenderAllButton, theAllFilter: .GenderAllFilter)
                case .SexualityCategoryName?:
                    let buttonMinusAllButtonArray : [UIButton] = [theSexualityGayButton, theSexualityBisexualButton, theSexualityStraightButton]
                    changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: buttonMinusAllButtonArray, categoryArray: FilterNames.sexualityMinusAllValues, theAllButton: theSexualityAllButton, theAllFilter: .SexualityAllFilter)
                default: break
                }
            }
        }
    }
    
    //this method is to change the button highlights if all was pushed, or if all is pushed and someone presses another button
    func changeButtonHighlightsAndDictionaryValues(categoryName: FilterCategories, filterName: FilterNames, buttonArray: [UIButton], categoryArray: [FilterNames], theAllButton: UIButton, theAllFilter: FilterNames) {
        if FilterNames.theAllButtonValues.contains(filterName) {
            //this means the button pressed was an all button
            for button in buttonArray {
                changeButtonBackground(button, currentState: true)
            }
            //reseting all the filter states to false, because we want all races in the query. Which, is the default query.
            for filterName in categoryArray {
                filterDictionary[filterName] = (filterState: false, filterCategory: categoryName)
            }
        } else {
            //it is not the all button, so change the all-button state and button color.
            changeButtonBackground(theAllButton, currentState: true)
            filterDictionary[theAllFilter] = (filterState: false, filterCategory: categoryName)
        }
    }
    
    func changeButtonBackground(button: UIButton, currentState: Bool) {
        if currentState {
            //button needs to be unhighlighted/returned to normal state
            button.backgroundColor = ChachaBombayGrey
            button.setTitleColor(ChachaTeal, forState: .Normal)
        } else {
            //button should become highlighted
            button.backgroundColor = ChachaTeal
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
    }

    
    @IBAction func save(sender: AnyObject) {
        createFilteredUserArray()
    }
    
    @IBAction func distanceSliderValueChanged(sender: AnyObject) {
        let distanceValue = round(theDistanceSlider.value)
        if distanceValue >= 101 {
            theDistanceMilesLabel.text = "100+ mi."
        } else {
            theDistanceMilesLabel.text = "\(Int(distanceValue)) mi."
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        let locationManager = CLLocationManager()
//        locationManager.requestWhenInUseAuthorization()
        createFilterDictionary()
        getUserLocation()
        setGUI()
    }
    
    func createFilterDictionary() {
        for filterName in FilterNames.raceMinusAllValues {
            filterDictionary[filterName] = (filterState: false, filterCategory: FilterCategories.RaceCategoryName)
        }
        for filterName in FilterNames.hairColorMinusAllValues {
            filterDictionary[filterName] = (filterState: false, filterCategory: FilterCategories.HairColorCategoryName)
        }
        for filterName in FilterNames.politicalAffiliationMinusAllValues {
            filterDictionary[filterName] = (filterState: false, filterCategory: FilterCategories.PoliticalAffiliationCategoryName)
        }
        for filterName in FilterNames.genderMinusAllValues {
            filterDictionary[filterName] = (filterState: false, filterCategory: FilterCategories.GenderCategoryName)
        }
        for filterName in FilterNames.sexualityMinusAllValues {
            filterDictionary[filterName] = (filterState: false, filterCategory: FilterCategories.SexualityCategoryName)
        }
        filterDictionary[FilterNames.RaceAllFilter] = (filterState: true, filterCategory: FilterCategories.RaceCategoryName)
        filterDictionary[FilterNames.HairColorAllFilter] = (filterState: true, filterCategory: FilterCategories.HairColorCategoryName)
        filterDictionary[FilterNames.PoliticalAffiliationAllFilter] = (filterState: true, filterCategory: FilterCategories.PoliticalAffiliationCategoryName)
        filterDictionary[FilterNames.GenderAllFilter] = (filterState: true, filterCategory: FilterCategories.GenderCategoryName)
        filterDictionary[FilterNames.SexualityAllFilter] = (filterState: true, filterCategory: FilterCategories.SexualityCategoryName)
    }
    
    func setGUI() {
        setAgeSliderGUI()
        theSexualityAllButton.layer.cornerRadius = cornerSize
        theSexualityBisexualButton.layer.cornerRadius = cornerSize
        theSexualityGayButton.layer.cornerRadius = cornerSize
        theSexualityStraightButton.layer.cornerRadius = cornerSize
        theHairColorBrunetteButton.layer.cornerRadius = cornerSize
        theHairColorRedheadButton.layer.cornerRadius = cornerSize
        theHairColorBlondeButton.layer.cornerRadius = cornerSize
        theHairColorAllButton.layer.cornerRadius = cornerSize
        theDistanceGraySliderView.layer.cornerRadius = cornerSize
        theAgeRangeSlider.layer.cornerRadius = cornerSize
        theRaceAsianButton.layer.cornerRadius = cornerSize
        theRaceBlackButton.layer.cornerRadius = cornerSize
        theRaceLatinoButton.layer.cornerRadius = cornerSize
        theRaceWhiteButton.layer.cornerRadius = cornerSize
        theRaceAllButton.layer.cornerRadius = cornerSize
        thePoliticAllButton.layer.cornerRadius = cornerSize
        thePoliticDemocratButton.layer.cornerRadius = cornerSize
        thePoliticRepublicanButton.layer.cornerRadius = cornerSize
        theGenderMaleButton.layer.cornerRadius = cornerSize
        theGenderFemaleButton.layer.cornerRadius = cornerSize
        theGenderAllButton.layer.cornerRadius = cornerSize
    }
    
    func setAgeSliderGUI() {
        theAgeRangeSlider.tintColor = PeriwinkleGray
        theAgeRangeSlider.tintColorBetweenHandles = ChachaTeal
        theAgeRangeSlider.handleDiameter = 27
        theAgeRangeSlider.selectedHandleDiameterMultiplier = 1.2
    }
    
    //for creating the lines between the buttons. I create spacing with the stack view and then place a view with background color behind it to fill in the spaces.
//    func createBackgroundView(stackView: UIStackView, holderView: UIView) {
//        let backgroundColorView = UIView()
//        backgroundColorView.backgroundColor = FilteringPageStackViewLinesColor
//        holderView.insertSubview(backgroundColorView, belowSubview: stackView)
//        backgroundColorView.snp_makeConstraints { (make) -> Void in
//            make.edges.equalTo(stackView).inset(UIEdgeInsetsMake(0, 20, 0, 20))
//        }
//    }
    
    //left button means we want the corners to be on the top and bottom left. If false, then we want right side corners.
//    func maskButton(button: UIButton, leftButton: Bool) {
//        let maskLayer = CAShapeLayer()
//        if leftButton {
//             maskLayer.path = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: UIRectCorner.TopLeft.union(.BottomLeft), cornerRadii: CGSizeMake(cornerSize, cornerSize)).CGPath
//        } else {
//            //button is on the right side
//            maskLayer.path = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: UIRectCorner.TopRight.union(.BottomRight), cornerRadii: CGSizeMake(cornerSize, cornerSize)).CGPath
//        }
//        
//        button.layer.mask = maskLayer
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

//create new user query for the card stack.
extension FilterViewController {
    
    //running this query in view did load. It loads while they are choosing filters. So, we get their new location. If not loaded by the time they hit save, we just use the users last location.
    func getUserLocation() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                // do something with the new geoPoint
                self.currentUser?.location = geoPoint
                self.currentUser?.saveInBackground()
                self.currentUserLocation = geoPoint
            } else {
                print(error)
            }
        }
    }
    
    func createFilteredUserArray() {
            let query = User.query()
            //the where clause checks if the all button is checked, in which case, there should be now whereKey on the query for that particular category.
            for (filterName, filterDictionaryTuple) in filterDictionary where !FilterNames.theAllButtonValues.contains(filterName) {
                //checks if the button is clicked
                if filterDictionaryTuple.filterState {
                   query?.whereKey(filterDictionaryTuple.filterCategory.rawValue, equalTo: filterName.rawValue)
                }
            }
            if let currentUserLocation = currentUserLocation {
                query?.whereKey("location", nearGeoPoint: currentUserLocation, withinMiles: Double(theDistanceSlider.value))
            }
            query?.whereKey("objectId", notEqualTo: (currentUser!.objectId)!)
            query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let users = objects as? [User] {
                    self.delegate?.passFilteredUserArray(users)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
    }
}


extension FilterViewController: TTRangeSliderDelegate {
    func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        let ageMaxValue = round(theAgeRangeSlider.selectedMaximum)
        let ageMinValue = round(theAgeRangeSlider.selectedMinimum)
        if ageMaxValue >= 65 {
            theAgeRangeLabel.text = "\(Int(ageMinValue)) - \(Int(ageMaxValue))+"
        } else {
            theAgeRangeLabel.text = "\(Int(ageMinValue)) - \(Int(ageMaxValue))"
        }
    }
}

