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
import Timepiece
import EFTools

public enum FilterUserMode {
    case UserEditingMode
    case FilteringMode
}

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
    @IBOutlet weak var theHairColorStackView: UIStackView!
    @IBOutlet weak var theHairColorBrunetteButton: UIButton!
    @IBOutlet weak var theHairColorRedheadButton: UIButton!
    @IBOutlet weak var theHairColorBlondeButton: UIButton!
    @IBOutlet weak var theHairColorAllButton: UIButton!
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
    @IBOutlet weak var theSaveButton: UIButton!
    @IBOutlet weak var theMaximumDistanceHolderView: UIView!
    @IBOutlet weak var theMainStackView: UIStackView!
    @IBOutlet weak var theAgeRangeHolderView: UIView!
    @IBOutlet weak var thePoliticStackView: UIStackView!
    @IBOutlet weak var theGenderStackView: UIStackView!
    @IBOutlet weak var theSexualityStackView: UIStackView!
    @IBOutlet weak var thePageTitle: UILabel!
    
    var currentUserLocation : PFGeoPoint? = User.currentUser()?.location
    let currentUser = User.currentUser()
    
    var filterDictionary = [FilterNames : (filterState: Bool, filterCategory: FilterCategories)]()
    
    var filterUserMode : FilterUserMode = .FilteringMode
    var delegate: FilterViewControllerDelegate?
    var fromOnboarding = false
    
    
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
        static let raceAllValues = [RaceBlackFilter, RaceWhiteFilter, RaceLatinoFilter, RaceAsianFilter, RaceAllFilter]
        static let hairColorAllValues = [HairColorBrunetteFilter, HairColorBlondeFilter, HairColorRedheadFilter, HairColorAllFilter]
        static var genderAllValues = [GenderMaleFilter, GenderFemaleFilter, GenderAllFilter]
        static let sexualityAllValues = [SexualityStraightFilter, SexualityGayFilter, SexualityBisexualFilter, SexualityAllFilter]
        static let politicalAffiliationAllValues = [PoliticalAffiliationDemocratFilter, PoliticalAffiliationRepublicanFilter, PoliticalAffiliationAllFilter]
        static let raceMinusAllValues = [RaceBlackFilter, RaceWhiteFilter, RaceLatinoFilter, RaceAsianFilter]
        static let hairColorMinusAllValues = [HairColorBrunetteFilter, HairColorBlondeFilter, HairColorRedheadFilter]
        static var genderMinusAllValues = [GenderMaleFilter, GenderFemaleFilter]
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
                    if filterUserMode == .UserEditingMode {
                        chooseOneButton(filterDictionaryCurrentFilterCategory!, filterName: filterName, filterNamesArray: FilterNames.raceAllValues, pushedButton: button, buttonArray: theRaceStackView.arrangedSubviews as! [UIButton])
                    } else if filterUserMode == .FilteringMode {
                        changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: theRaceStackView.arrangedSubviews as! [UIButton], categoryArray: FilterNames.raceMinusAllValues, theAllFilter: .RaceAllFilter)
                    }
                case .HairColorCategoryName?:
                    if filterUserMode == .UserEditingMode {
                        chooseOneButton(filterDictionaryCurrentFilterCategory!, filterName: filterName, filterNamesArray: FilterNames.hairColorAllValues, pushedButton: button, buttonArray: theHairColorStackView.arrangedSubviews as! [UIButton])
                    } else if filterUserMode == .FilteringMode {
                        changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: theHairColorStackView.arrangedSubviews as! [UIButton], categoryArray: FilterNames.hairColorMinusAllValues, theAllFilter: .HairColorAllFilter)
                    }
                case .PoliticalAffiliationCategoryName?:
                    if filterUserMode == .UserEditingMode {
                        chooseOneButton(filterDictionaryCurrentFilterCategory!, filterName: filterName, filterNamesArray: FilterNames.politicalAffiliationAllValues, pushedButton: button, buttonArray: thePoliticStackView.arrangedSubviews as! [UIButton])
                    } else if filterUserMode == .FilteringMode {
                        changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: thePoliticStackView.arrangedSubviews as! [UIButton], categoryArray: FilterNames.politicalAffiliationMinusAllValues, theAllFilter: .PoliticalAffiliationAllFilter)
                    }
                case .GenderCategoryName?:
                    if filterUserMode == .UserEditingMode {
                        chooseOneButton(filterDictionaryCurrentFilterCategory!, filterName: filterName, filterNamesArray: FilterNames.genderAllValues, pushedButton: button, buttonArray: theGenderStackView.arrangedSubviews as! [UIButton])
                    } else if filterUserMode == .FilteringMode {
                         changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: theGenderStackView.arrangedSubviews as! [UIButton], categoryArray: FilterNames.genderMinusAllValues, theAllFilter: .GenderAllFilter)
                    }
                case .SexualityCategoryName?:
                    if filterUserMode == .UserEditingMode {
                        chooseOneButton(filterDictionaryCurrentFilterCategory!, filterName: filterName, filterNamesArray: FilterNames.sexualityAllValues, pushedButton: button, buttonArray: theSexualityStackView.arrangedSubviews as! [UIButton])
                    } else if filterUserMode == .FilteringMode {
                        changeButtonHighlightsAndDictionaryValues(filterDictionaryCurrentFilterCategory!, filterName: filterName, buttonArray: theSexualityStackView.arrangedSubviews as! [UIButton], categoryArray: FilterNames.sexualityMinusAllValues, theAllFilter: .SexualityAllFilter)
                    }
                default: break
                }
            }
        }
    }
    
    //this method is to change the button highlights if all was pushed, or if all is pushed and someone presses another button
    func changeButtonHighlightsAndDictionaryValues(categoryName: FilterCategories, filterName: FilterNames, buttonArray: [UIButton], categoryArray: [FilterNames], theAllFilter: FilterNames) {
        if FilterNames.theAllButtonValues.contains(filterName) {
            //this means the button pressed was an all button
            for index in 0...buttonArray.count - 2 {
                changeButtonBackground(buttonArray[index], currentState: true)
            }
            //reseting all the filter states to false, because we want all races in the query. Which, is the default query.
            for filterName in categoryArray {
                filterDictionary[filterName] = (filterState: false, filterCategory: categoryName)
            }
        } else {
            //it is not the all button, so change the all-button state and button color.
            changeButtonBackground(buttonArray[buttonArray.count - 1], currentState: true)
            filterDictionary[theAllFilter] = (filterState: false, filterCategory: categoryName)
        }
    }
    
    //you can only push one button when inputing your characteristics
    func chooseOneButton (filterCategory: FilterCategories, filterName: FilterNames, filterNamesArray: [FilterNames], pushedButton: UIButton, buttonArray: [UIButton]) {
        for button in buttonArray {
            if button == pushedButton {
                //set the pushed button to highlighted
                changeButtonBackground(pushedButton, currentState: false)
            } else {
                //set the non-pushed buttons all to unhighlighted
                changeButtonBackground(button, currentState: true)
            }
        }
        
        //set the correct values in the dictionary
        for filter in filterNamesArray {
            if filter == filterName {
                filterDictionary[filter] = (filterState: true, filterCategory: filterCategory)
            } else {
                //every other filter name becomes false
                filterDictionary[filter] = (filterState: false, filterCategory: filterCategory)
            }
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
        if filterUserMode == .UserEditingMode {
            saveUserCharacteristics()
        } else if filterUserMode == .FilteringMode {
            createFilteredUserArray()
        }
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
        createFilterDictionary()
        getUserLocation()
        setGUI()
    }
    
    override func viewDidAppear(animated: Bool) {
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
        setRoundedCorners()
        if filterUserMode == .UserEditingMode {
            setInputModeGUI()
        }
    }
    
    func setRoundedCorners() {
        let cornerSize : CGFloat = 10
        let stackViewArray = [theRaceStackView, theHairColorStackView, theGenderStackView, thePoliticStackView, theSexualityStackView]
        for stackView in stackViewArray {
            for button in stackView.arrangedSubviews {
                button.layer.cornerRadius = cornerSize
            }
        }
        //set the other corners
        theAgeRangeSlider.layer.cornerRadius = cornerSize
        theDistanceGraySliderView.layer.cornerRadius = cornerSize
        theSaveButton.layer.cornerRadius = 0.5 * theSaveButton.bounds.size.width
    }
    
    func setInputModeGUI() {
        removeFromMainStackView(theMaximumDistanceHolderView)
        removeFromMainStackView(theAgeRangeHolderView)
        setSkipButtonText([theRaceAllButton, theHairColorAllButton, thePoliticAllButton, theGenderAllButton, theSexualityAllButton])
        thePageTitle.text = "Who Are You?"
    }
    
    func setSkipButtonText(buttonArray: [UIButton]) {
        for button in buttonArray {
            button.setTitle("Skip", forState: .Normal)
        }
    }
    
    func removeFromMainStackView(view: UIView) {
        theMainStackView.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func setAgeSliderGUI() {
        theAgeRangeSlider.tintColor = PeriwinkleGray
        theAgeRangeSlider.tintColorBetweenHandles = ChachaTeal
        theAgeRangeSlider.handleDiameter = 27
        theAgeRangeSlider.selectedHandleDiameterMultiplier = 1.2
    }

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
    
    func saveUserCharacteristics() {
        let currentUser = User.currentUser()!
        for (filterName, filterDictionaryTuple) in filterDictionary {
            //checks if the button is clicked
            if filterDictionaryTuple.filterState {
            if FilterNames.raceAllValues.contains(filterName) {
                if filterName == .RaceAllFilter {
                    //the user does not want to be queried upon for this particular field.
                    currentUser.removeObjectForKey("race")
                } else {
                    //set the appropriate value to the user
                    currentUser.race = filterName.rawValue
                }
            } else if FilterNames.hairColorAllValues.contains(filterName) {
                if filterName == .HairColorAllFilter {
                    //the user does not want to be queried upon for this particular field.
                    currentUser.removeObjectForKey("hairColor")
                } else {
                    //set the appropriate value to the user
                    currentUser.hairColor = filterName.rawValue
                }
            } else if FilterNames.politicalAffiliationAllValues.contains(filterName) {
                if filterName == .PoliticalAffiliationAllFilter {
                    //the user does not want to be queried upon for this particular field.
                    currentUser.removeObjectForKey("politicalAffiliation")
                } else {
                    //set the appropriate value to the user
                    currentUser.politicalAffiliation = filterName.rawValue
                }
            } else if FilterNames.genderAllValues.contains(filterName) {
                if filterName == .GenderAllFilter {
                    //the user does not want to be queried upon for this particular field.
                    currentUser.removeObjectForKey("gender")
                } else {
                    //set the appropriate value to the user
                    currentUser.gender = filterName.rawValue
                }
            } else if FilterNames.sexualityAllValues.contains(filterName) {
                if filterName == .SexualityAllFilter {
                    //the user does not want to be queried upon for this particular field.
                    currentUser.removeObjectForKey("sexuality")
                } else {
                    //set the appropriate value to the user
                    currentUser.sexuality = filterName.rawValue
                }
                }
            }
        }
        currentUser.saveInBackgroundWithBlock { (success, error) in
            if success {
                if self.fromOnboarding {
                    self.performSegueWithIdentifier(.FilterPageToSignUpPageSegue, sender: self)
                } else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            } else {
                let _ = Alert(title: "Saving Error", subtitle: "there was an error saving you characteristics. Please try again.", closeButtonTitle: "Okay", closeButtonHidden: false, type: .Error)
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
            //don't need the query if the user wants 100+ miles. That just means all users. 
            if let currentUserLocation = currentUserLocation where theDistanceSlider.value <= 100 {
                query?.whereKey("location", nearGeoPoint: currentUserLocation, withinMiles: Double(theDistanceSlider.value))
            }
            let minMaxDateRange = createMinMaxDateRange(theAgeRangeSlider.selectedMaximum, minAge: theAgeRangeSlider.selectedMinimum)
            //if the max age chosen was 65+, then there is no need to set an upper age limit.
            if theAgeRangeSlider.selectedMaximum < 65 {
                query?.whereKey("birthDate", lessThanOrEqualTo: minMaxDateRange.maxDate)
            }
            query?.whereKey("birthDate", greaterThanOrEqualTo: minMaxDateRange.minDate)
            query?.whereKey("objectId", notEqualTo: (currentUser!.objectId)!)
            query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let users = objects as? [User] {
                    self.delegate?.passFilteredUserArray(users)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
    }
    
    func createMinMaxDateRange(maxAge: Float, minAge: Float) -> (minDate: NSDate, maxDate: NSDate) {
        let now = NSDate()
        //minDate means the oldest person/earliest year.
        let minDate = now.change(year: now.year - Int(maxAge))
        //maxDate means the youngest person/latest year.
        let maxDate = now.change(year: now.year - Int(minAge))
        return (minDate: minDate, maxDate: maxDate)
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

extension FilterViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case FilterToMainPageSegue
        case FilterPageToSignUpPageSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .FilterToMainPageSegue: break
        default: break
        }
    }
    
}


