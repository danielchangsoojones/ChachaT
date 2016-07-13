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
import Parse

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
    var theSpecialtyTagEnviromentHolderView : SpecialtyTagEnviromentHolderView?
    @IBOutlet weak var theChosenTagHolderView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    
    var allParseTags: [Tag] = []
    var currentUserTags: [Tag] = []
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        
    }
    
    //search Variables
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addTagListViewAttributes()
        loadData()
        setDataArray()
    }
    
    func addTagListViewAttributes() {
        //did this in code, rather than total storyboard because it has a lot of redundancy
        tagChoicesView.addChoicesTagListViewAttributes()
        tagChosenView.addChosenTagListViewAttributes()
    }
    
    func loadData() {
        setChoicesViewTags()
    }
    
    //move to actual filtering page
    func setChoicesViewTags() {
        for tag in currentUserTags {
            var prefixString = ""
            let semiColonString = ": "
            switch tag.attribute {
            case TagAttributes.Generic.rawValue: break
            case TagAttributes.SpecialtyButtons.rawValue:
                if let categoryName = findFilterNameCategory(tag.title) {
                    prefixString = categoryName.rawValue + semiColonString
                }
            case TagAttributes.SpecialtyRangeSlider.rawValue:
                prefixString = SpecialtyTags.AgeRange.rawValue + semiColonString
            case TagAttributes.SpecialtySingleSlider.rawValue:
                prefixString = SpecialtyTags.Location.rawValue + semiColonString
            default: break
            }
            tagChoicesView.addTag(prefixString + tag.title)
        }
    }
    
    //Purpose: to find which specialty group we are dealing with
    //For Example: It figures out whether the given string should be with Hair Color, Race, ect.
    func findFilterNameCategory(tagTitle: String) -> SpecialtyTags? {
        for filterName in FilterNames.allValues where filterName.rawValue == tagTitle {
                //we have a specialty generic tag
                if FilterNames.genderAllValues.contains(filterName) {
                    return .Gender
                } else if FilterNames.hairColorAllValues.contains(filterName) {
                    return .HairColor
                } else if FilterNames.sexualityAllValues.contains(filterName) {
                    return .Sexuality
                } else if FilterNames.politicalAffiliationAllValues.contains(filterName) {
                    return .PoliticalAffiliation
                } else if FilterNames.raceAllValues.contains(filterName) {
                    return .Race
                }
        }
        //return nil because it was in none of the above cases, shouldn't reach this point
        return nil
    }
    
    //move to actual filtering page
    //this adds specialty tags to the dictionary
//    func setTagsInTagDictionary() {
//        for defaultGenericTag in FilterNames.allValues {
//            //setting generic tags that are pre-set like (Male, Black, ect.)
//            currentUserTagDictionary[Tag(title: defaultGenericTag.rawValue)] = TagAttributes.Generic
//        }
//        //sets speciality tags like Gender, Sexuality, ect. because they create a special animation
//        for specialtyButtonTag in SpecialtyTags.specialtyButtonValues {
//            currentUserTagDictionary[Tag(title: specialtyButtonTag.rawValue)] = TagAttributes.SpecialtyButtons
//        }
//        for specialtySingleSliderTag in SpecialtyTags.specialtySingleSliderValues {
//            currentUserTagDictionary[Tag(title: specialtySingleSliderTag.rawValue)] = TagAttributes.SpecialtySingleSlider
//        }
//        for specialtyRangeSliderTag in SpecialtyTags.specialtyRangeSliderValues {
//            currentUserTagDictionary[Tag(title: specialtyRangeSliderTag.rawValue)] = TagAttributes.SpecialtyRangeSlider
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FilterTagViewController: TagListViewDelegate {
//    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
//        //the tag from the choices tag view was pressed
//        if sender.tag == 1 {
//            if let tagAttribute = currentUserTagDictionary[title] {
//                switch tagAttribute {
//                case .Generic:
//                    changeTagListViewWidth(tagView, extend: true)
//                    self.tagChoicesView.removeTag(title)
//                    if !tagExistsInChosenTagListView(tagChosenView, title: title) {
//                        self.tagChosenView.addTag(title)
//                    }
//                case .SpecialtyButtons:
//                    createStackViewTagButtonsAndSpecialtyEnviroment(title, pushOneButton: true)
//                case .SpecialtySingleSlider:
//                    theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .DistanceSlider)
//                    createSpecialtyTagEnviroment(false)
//                case .SpecialtyRangeSlider:
//                    theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .AgeRangeSlider)
//                    createSpecialtyTagEnviroment(false)
//                }
//            }
//        }
//    }
    
    func createStackViewTagButtonsAndSpecialtyEnviroment(categoryTitleText: String, pushOneButton: Bool) {
        theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(filterCategory: categoryTitleText, addNoneButton: true, stackViewButtonDelegate: self, pushOneButton: pushOneButton)
        createSpecialtyTagEnviroment(false)
    }
    
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
            if !self.view.subviews.contains(theSpecialtyTagEnviromentHolderView) && !specialtyEnviromentHidden {
                //checking if the holder view has been added to the view, because we need to add it, if it has not. 
                //we also want to make sure that the specialtyTagEnviromentView is supposed to be shown
                self.view.addSubview(theSpecialtyTagEnviromentHolderView)
                theSpecialtyTagEnviromentHolderView.snp_makeConstraints(closure: { (make) in
                    let leadingTrailingOffset : CGFloat = 20
                    make.leading.equalTo(self.view).offset(leadingTrailingOffset)
                    make.trailing.equalTo(self.view).offset(-leadingTrailingOffset)
                    make.top.equalTo(theChosenTagHolderView.snp_bottom)
                    make.bottom.equalTo(self.view)
                })
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
    
    //need to override in subclass method
    func addToProfileTagArray(title: String) {}
}

//search extension
extension FilterTagViewController {
    //TODO; right now, my search is pulling down the entire tag table and then doing search,
    //very ineffecient, and in future, I will have to do server side cloud code.
    //Also, it is pulling down duplicate tag titles, Example: Two Users might have a blonde tag, but for searching purposes, I only need to have one blonde tag. Right now pulling down all tags, which again is ineffecient
    func setDataArray() {
        var alreadyContainsTagArray: [String] = []
        let query = PFQuery(className: "Tag")
        query.selectKeys(["title"])
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                for tag in tags {
                    if !alreadyContainsTagArray.contains(tag.title) {
                        //our string array does not already contain the tag title, so we can add it to our searchable array
                        alreadyContainsTagArray.append(tag.title)
                        self.allParseTags.append(tag)
                    }
                }
            }
        }
    }
}





