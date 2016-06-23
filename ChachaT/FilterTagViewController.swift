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

class FilterTagViewController: OverlayAnonymousFlowViewController {
    
    @IBOutlet weak var tagChoicesView: TagListView!
    @IBOutlet weak var tagChosenView: TagListView!
    @IBOutlet weak var tagChosenViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var theCategoryLabel: UILabel!
    @IBOutlet weak var theDoneSpecialtyButton: UIButton!
    @IBOutlet weak var theSpecialtyTagEnviromentHolderView: UIView!
    var theStackViewTagsButtons : StackViewTagButtons?
    var theDistanceSliderView : DistanceSliderView?
    var theAgeRangeSliderView : AgeDoubleRangeSliderView?
    
    var normalTags = [String]()
    var tagDictionary = [String : TagAttributes]()
    
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
        if let theDistanceSlider = theDistanceSliderView {
            theDistanceSlider.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSpecialtyTagsInTagDictionary()
        setTagsFromDictionary()
        tagChoicesView.delegate = self
        tagChoicesView.alignment = .Center
        tagChosenView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func setTagsFromDictionary() {
        for (tagName, tagAttribute) in tagDictionary {
            tagChoicesView.addTag(tagName)
        }
    }
    
    //sets speciality tags like Gender, Sexuality, ect. because they create a special animation
    func setSpecialtyTagsInTagDictionary() {
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

extension FilterTagViewController: TagListViewDelegate {
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        //the tag from the choices tag view was pressed
        if sender.tag == 1 {
            let tagAttribute = tagDictionary[title]!
            switch tagAttribute {
            case .Generic:
                changeTagListViewWidth(tagView, extend: true)
                self.tagChoicesView.removeTag(title)
                self.tagChosenView.addTag(title)
            case .SpecialtyButtons:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                theStackViewTagsButtons = createStackViewTagButtons()
                theStackViewTagsButtons!.addButtonToStackView(title)
            case .SpecialtySingleSlider:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                createDistanceSliderView()
            case .SpecialtyRangeSlider:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                createAgeRangeSliderView()
            }
           
        }
    }
    
    func createDistanceSliderView() {
        //the frame gets overrided by the snp_constraints
        theDistanceSliderView = DistanceSliderView(frame: CGRectMake(0, 0, 200, 200))
        //had to set the initial value for the slider here because not loading when I put in the slider view class
        theDistanceSliderView!.distanceSlider.setValue(50.0, animated: false)
        self.theSpecialtyTagEnviromentHolderView.addSubview(theDistanceSliderView!)
        theDistanceSliderView!.snp_makeConstraints { (make) in
            make.leading.equalTo(theSpecialtyTagEnviromentHolderView).offset(8)
            make.trailing.equalTo(theSpecialtyTagEnviromentHolderView).offset(-8)
            make.top.equalTo(theCategoryLabel).offset(100)
            make.height.equalTo(30)
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
        //added the + 1 because the tag view was getting rounded down, so when I would delete tags, the next tag wouldn't have enough roomto stay on the same line
        let tagWidth = tagView.intrinsicContentSize().width + 1
        //TODO: Can't figure out how the marginX is being applied, so the math is a guestimate right now.
        let tagPadding : CGFloat = self.tagChosenView.marginX
        if extend {
            //we are adding a tag, and need to make more room
            self.tagChosenViewWidthConstraint.constant += tagWidth + tagPadding
        } else {
            //deleting a tag, so shrink view
            self.tagChosenViewWidthConstraint.constant -= tagWidth + tagPadding
        }
        self.view.layoutIfNeeded()
    }
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        changeTagListViewWidth(tagView, extend: false)
        sender.removeTagView(tagView)
    }
}

extension FilterTagViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.showsCancelButton = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let data = setDataArray()
        var filtered:[String] = []
        tagChoicesView.removeAllTags()
        filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false
        } else {
            searchActive = true
            for tag in filtered {
                tagChoicesView.addTag(tag)
            }
        }
    }
    
    func setDataArray() -> [String] {
        var dataArray = [String]()
        for (tagName, _) in tagDictionary {
            dataArray.append(tagName)
        }
        return dataArray
    }

}

extension FilterTagViewController: StackViewTagButtonsDelegate {
    func createChosenTag(tagTitle: String) {
        let tagView = tagChosenView.addTag(tagTitle)
        changeTagListViewWidth(tagView, extend: true)
    }
    
    func removeChosenTag(tagTitle: String) {
        tagChosenView.removeTag(tagTitle)
    }
    
    func createStackViewTagButtons() -> StackViewTagButtons {
        let stackView = StackViewTagButtons(frame: CGRectMake(0, 0, 100, 100))
        stackView.delegate = self
        self.theSpecialtyTagEnviromentHolderView.addSubview(stackView)
        stackView.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.view)
            make.centerX.equalTo(self.theSpecialtyTagEnviromentHolderView)
        }
        return stackView
    }
}





