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
    
    
    var normalTags = [String]()
    var tagDictionary = [String : TagAttributes]()
    
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
            self.tagChoicesView.removeTag(title)
            self.tagChosenView.addTag(title)
        }
    }
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
    }
}
