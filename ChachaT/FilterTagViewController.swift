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
    var theSpecialtyTagEnviromentHolderView : SpecialtyTagEnviromentHolderView?
    @IBOutlet weak var theChosenTagHolderView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
//    var theStackViewTagsButtons : StackViewTagButtons?
//    var theDistanceSliderView : DistanceSliderView?
//    var theAgeRangeSliderView : AgeDoubleRangeSliderView?
    
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
        if let theSpecialtyTagEnviromentHolderView = theSpecialtyTagEnviromentHolderView {
            theSpecialtyTagEnviromentHolderView.theSpecialtyView?.removeFromSuperview()
        }
        createSpecialtyTagEnviroment(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTagsInTagDictionary()
        loadData()
        tagChoicesView.alignment = .Center
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        setTagsFromDictionary()
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
    
    func createSpecialtyTagEnviroment(specialtyEnviromentHidden: Bool) {
        tagChoicesView.hidden = !specialtyEnviromentHidden
        if let theSpecialtyTagEnviromentHolderView = theSpecialtyTagEnviromentHolderView {
            if !self.view.subviews.contains(theSpecialtyTagEnviromentHolderView) {
                //checking if the holder view has been added to the view, because we need to add it, if it has not. 
                self.view.addSubview(theSpecialtyTagEnviromentHolderView)
            }
            for subview in theSpecialtyTagEnviromentHolderView.subviews {
                subview.hidden = specialtyEnviromentHidden
            }
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

    func removeChoicesTag(tagTitle: String) {
        tagChoicesView.removeTag(tagTitle)
    }
    
    func doesChosenTagViewContain(tagTitle: String) -> Bool {
        return tagExistsInChosenTagListView(tagChosenView, title: tagTitle)
    }
}

extension FilterTagViewController: SpecialtyTagEnviromentHolderViewDelegate {
    func unhideChoicesTagListView() {
        createSpecialtyTagEnviroment(true)
    }
}





