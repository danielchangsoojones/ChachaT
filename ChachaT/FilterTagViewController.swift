//
//  FilterTagViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import TagListView
import SnapKit

public enum SpecialtyTags : String {
    case Gender
    case Race
    case Sexuality
    case AgeRange = "Age Range"
    case PoliticalAffiliation = "Political Affiliation"
    case HairColor = "Hair Color"
    case Location
    static let specialtyButtonValues = [Gender, Race, Sexuality, PoliticalAffiliation, HairColor]
    static let specialtySingleSliderValues = [Location]
    static let specialtyRangeSliderValues = [AgeRange]
}

public enum FilterNames : String {
    case RaceBlackFilter = "Black"
    case RaceWhiteFilter = "White"
    case RaceLatinoFilter = "Latino"
    case RaceAsianFilter = "Asian"
    case HairColorBrunetteFilter = "Brunette"
    case HairColorBlondeFilter = "Blonde"
    case HairColorRedheadFilter = "Redhead"
    case PoliticalAffiliationDemocratFilter = "Democrat"
    case PoliticalAffiliationRepublicanFilter = "Republican"
    case GenderMaleFilter = "Male"
    case GenderFemaleFilter = "Female"
    case SexualityStraightFilter = "Straight"
    case SexualityGayFilter = "Gay"
    case SexualityBisexualFilter = "Bisexual"
    
    //this array lets me iterate over certain sections of the enum
    static let raceAllValues = [RaceBlackFilter, RaceWhiteFilter, RaceLatinoFilter, RaceAsianFilter]
    static let hairColorAllValues = [HairColorBrunetteFilter, HairColorBlondeFilter, HairColorRedheadFilter]
    static let genderAllValues = [GenderMaleFilter, GenderFemaleFilter]
    static let sexualityAllValues = [SexualityStraightFilter, SexualityGayFilter, SexualityBisexualFilter]
    static let politicalAffiliationAllValues = [PoliticalAffiliationDemocratFilter, PoliticalAffiliationRepublicanFilter]
    static let allValues = [RaceBlackFilter, RaceWhiteFilter, RaceLatinoFilter, RaceAsianFilter, HairColorBrunetteFilter, HairColorBlondeFilter, HairColorRedheadFilter, GenderMaleFilter, GenderFemaleFilter, SexualityStraightFilter, SexualityGayFilter, SexualityBisexualFilter, PoliticalAffiliationDemocratFilter, PoliticalAffiliationRepublicanFilter]
}

class FilterTagViewController: OverlayAnonymousFlowViewController {
    
    @IBOutlet weak var tagChoicesView: TagListView!
    @IBOutlet weak var tagChosenView: TagListView!
    @IBOutlet weak var tagChosenViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var theCategoryLabel: UILabel!
    @IBOutlet weak var theDoneSpecialtyButton: UIButton!
    @IBOutlet weak var theSpecialtyTagEnviromentHolderView: UIView!
    @IBOutlet weak var theChosenTagHolderView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    var theStackViewTagsButtons : StackViewTagButtons?
    var theDistanceSliderView : DistanceSliderView?
    var theAgeRangeSliderView : AgeDoubleRangeSliderView?
    
    var normalTags = [String]()
    var tagDictionary = [String : TagAttributes]()
    let createTagButtonText = "Create"
    
    //search Variables
    var searchActive : Bool = false
    
    enum TagAttributes {
        case Generic
        case SpecialtyButtons
        case SpecialtySingleSlider
        case SpecialtyRangeSlider
    }
    
    @IBAction func doneSpecialtyButtonPressed(sender: UIButton) {
        createSpecialtyTagEnviroment(true, categoryTitleText: nil)
        if let theStackViewTagsButtons = theStackViewTagsButtons {
            theStackViewTagsButtons.removeFromSuperview()
        }
        if let theDistanceSliderView = theDistanceSliderView {
            theDistanceSliderView.removeFromSuperview()
        }
        if let theAgeRangeSliderView = theAgeRangeSliderView {
            theAgeRangeSliderView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTagsInTagDictionary()
        setTagsFromDictionary()
        
        tagChoicesView.alignment = .Center
        // Do any additional setup after loading the view.
    }
    
    //move to actual filtering page
    func setTagsFromDictionary() {
        for (tagName, tagAttribute) in tagDictionary {
            tagChoicesView.addTag(tagName)
        }
    }
    
    //move to actual filtering page
    func setTagsInTagDictionary() {
        for defaultGenericTag in FilterNames.allValues {
            //setting generic tags that are pre-set like (Male, Black, ect.)
            tagDictionary[defaultGenericTag.rawValue] = TagAttributes.Generic
        }
        //sets speciality tags like Gender, Sexuality, ect. because they create a special animation
        for specialtyButtonTag in SpecialtyTags.specialtyButtonValues {
            tagDictionary[specialtyButtonTag.rawValue] = TagAttributes.SpecialtyButtons
        }
        for specialtySingleSliderTag in SpecialtyTags.specialtySingleSliderValues {
            tagDictionary[specialtySingleSliderTag.rawValue] = TagAttributes.SpecialtySingleSlider
        }
        for specialtyRangeSliderTag in SpecialtyTags.specialtyRangeSliderValues {
            tagDictionary[specialtyRangeSliderTag.rawValue] = TagAttributes.SpecialtyRangeSlider
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FilterTagViewController {
//    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
//        //the tag from the choices tag view was pressed
//        if sender.tag == 1 {
//            let tagAttribute = tagDictionary[title]!
//            switch tagAttribute {
//            case .Generic:
//                changeTagListViewWidth(tagView, extend: true)
//                self.tagChoicesView.removeTag(title)
//                if !tagExistsInChosenTagListView(tagChosenView, title: title) {
//                    self.tagChosenView.addTag(title)
//                }
//            case .SpecialtyButtons:
//                createSpecialtyTagEnviroment(false, categoryTitleText: title)
//                theStackViewTagsButtons = createStackViewTagButtons()
//                theStackViewTagsButtons!.addButtonToStackView(title)
//            case .SpecialtySingleSlider:
//                createSpecialtyTagEnviroment(false, categoryTitleText: title)
//                createDistanceSliderView()
//            case .SpecialtyRangeSlider:
//                createSpecialtyTagEnviroment(false, categoryTitleText: title)
//                createAgeRangeSliderView()
//            }
//           
//        }
//    }
    
    func tagExistsInChosenTagListView(tagListView: TagListView, title: String) -> Bool {
        let tagViews = tagListView.tagViews
        for tagView in tagViews {
            if tagView.titleLabel?.text == title {
                return true
            }
        }
        return false
    }

    func createDistanceSliderView() {
        //the frame gets overrided by the snp_constraints
        theDistanceSliderView = DistanceSliderView(frame: CGRectMake(0, 0, 200, 200))
        //had to set the initial value for the slider here because not loading when I put in the slider view class
        theDistanceSliderView!.theDistanceSlider.setValue(50.0, animated: false)
        self.theSpecialtyTagEnviromentHolderView.addSubview(theDistanceSliderView!)
        theDistanceSliderView!.snp_makeConstraints { (make) in
            make.leading.equalTo(theSpecialtyTagEnviromentHolderView).offset(8)
            make.trailing.equalTo(theSpecialtyTagEnviromentHolderView).offset(-8)
            make.top.equalTo(theCategoryLabel).offset(100)
            make.height.equalTo(50)
        }
    }
    
    func createAgeRangeSliderView() {
        theAgeRangeSliderView = AgeDoubleRangeSliderView(frame: CGRectMake(0, 0, 200, 200))
        theSpecialtyTagEnviromentHolderView.addSubview(theAgeRangeSliderView!)
        theAgeRangeSliderView?.snp_makeConstraints(closure: { (make) in
            make.leading.equalTo(theSpecialtyTagEnviromentHolderView).offset(8)
            make.trailing.equalTo(theSpecialtyTagEnviromentHolderView).offset(-8)
            make.top.equalTo(theCategoryLabel).offset(100)
            make.height.equalTo(30)
        })
    }
    
    func createSpecialtyTagEnviroment(specialtyEnviromentHidden: Bool, categoryTitleText: String?) {
        tagChoicesView.hidden = !specialtyEnviromentHidden
        for subview in theSpecialtyTagEnviromentHolderView.subviews {
            subview.hidden = specialtyEnviromentHidden
        }
        if let categoryTitleText = categoryTitleText {
            theCategoryLabel.text = categoryTitleText
        }
    }
    
    func changeTagListViewWidth(tagView: TagView, extend: Bool) {
        let originalTagChosenViewMaxX = tagChosenView.frame.maxX
        let tagWidth = tagView.intrinsicContentSize().width
        let tagPadding : CGFloat = self.tagChosenView.marginX
        //TODO: Not having the X remove button is not accounted for in the framework, so that was why the extension was not working because it was not including the X button.
        if extend {
            //we are adding a tag, and need to make more room
            self.tagChosenViewWidthConstraint.constant += tagWidth + tagPadding
        } else {
            //deleting a tag, so shrink view
            self.tagChosenViewWidthConstraint.constant -= tagWidth + tagPadding
        }
        self.view.layoutIfNeeded()
        if self.view.frame.width <= theChosenTagHolderView.frame.width {
            //TODO: did -100 because it looks better, and I could not figure out exact math. I want it to look like 8tracks, where after it grows bigger than the screen
            //it stays in the same spot
            theScrollView.setContentOffset(CGPointMake(originalTagChosenViewMaxX - 100, 0), animated: true)
        }
    }
    
//    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
//        changeTagListViewWidth(tagView, extend: false)
//        sender.removeTagView(tagView)
//    }
}

extension FilterTagViewController: StackViewTagButtonsDelegate {
    func createChosenTag(tagTitle: String) {
        let tagView = tagChosenView.addTag(tagTitle)
        changeTagListViewWidth(tagView, extend: true)
    }
    
    func removeChosenTag(tagTitle: String) {
        //finding the particular tagView, so we know what to pass to the changeTagListWidth
        //removeTag does not return a tagView like addTag does
        for tagView in tagChosenView.tagViews where tagView.currentTitle == tagTitle {
            tagChosenView.removeTag(tagTitle)
            changeTagListViewWidth(tagView, extend: false)
        }
    }
    
    func createStackViewTagButtons(filterCategory: String, addNoneButton: Bool) {
        let stackView = StackViewTagButtons(filterCategory: filterCategory, addNoneButton: addNoneButton, delegate: self)
        stackView.delegate = self
        self.theSpecialtyTagEnviromentHolderView.addSubview(stackView)
        stackView.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.view)
            make.centerX.equalTo(self.theSpecialtyTagEnviromentHolderView)
        }
        theStackViewTagsButtons = stackView
    }
    
    func doesChosenTagViewContain(tagTitle: String) -> Bool {
        return tagExistsInChosenTagListView(tagChosenView, title: tagTitle)
    }
}





