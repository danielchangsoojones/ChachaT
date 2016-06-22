//
//  FilterTagViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import TagListView

class FilterTagViewController: OverlayAnonymousFlowViewController {
    
    @IBOutlet weak var tagChoicesView: TagListView!
    @IBOutlet weak var tagChosenView: TagListView!
    @IBOutlet weak var tagChosenViewWidthConstraint: NSLayoutConstraint!
    
    
    var normalTags = [String]()
    var tagDictionary = [String : TagAttributes]()
    
    //search Variables
    var searchActive : Bool = false
    
    enum SpecialtyTags : String {
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
    
    enum TagAttributes {
        case Generic
        case SpecialtyButtons
        case SpecialtySingleSlider
        case SpecialtyRangeSlider
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
            changeTagListViewWidth(tagView, extend: true)
            self.tagChoicesView.removeTag(title)
            self.tagChosenView.addTag(title)
        }
    }
    
    func changeTagListViewWidth(tagView: TagView, extend: Bool) {
        let tagWidth = tagView.intrinsicContentSize().width
        //TODO: Can't figure out how the marginX is being applied, so the math is a guestimate right now.
        let tagPadding = self.tagChosenView.marginX * 3
        let extraPadding : CGFloat = 5
        if extend {
            //we are adding a tag, and need to make more room
            self.tagChosenViewWidthConstraint.constant += tagWidth + tagPadding + extraPadding
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
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
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


