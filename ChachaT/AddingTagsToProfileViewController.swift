//
//  AddingTagsToProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import TagListView
import Parse

class AddingTagsToProfileViewController: FilterTagViewController {
    
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var theAddToProfileButton: UIButton!
    
    @IBAction func addToProfilePressed(sender: UIButton) {
        theActivityIndicator.startAnimating()
        theActivityIndicator.hidden = false
        theAddToProfileButton.userInteractionEnabled = false
        var tagArray : [Tag] = []
        for tagView in tagChosenView.tagViews {
            let tag = Tag()
            if let title = tagView.currentTitle {
                tag.title = title
            }
            tag.createdBy = User.currentUser()
            tagArray.append(tag)
        }
        PFObject.saveAllInBackground(tagArray) { (success, error) in
            if success {
                self.theActivityIndicator.stopAnimating()
                self.theAddToProfileButton.userInteractionEnabled = true
            } else {
                print(error)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        changeTheChoicesTagView()
        tagChoicesView.delegate = self
        tagChosenView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func changeTheChoicesTagView() {
        //the user should be able to remove his/her tags because now they are editing them
        tagChoicesView.enableRemoveButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddingTagsToProfileViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        if sender.tag == 1 {
            //the remove button from theChoicesTagView was pressed
            let tagAttribute = tagDictionary[title]!
            switch tagAttribute {
            case .Generic:
                genericTagIsSpecial(title)
                //TODO: Remove from Parse Backend when the tag is removed or have it all removed once we hit done
            case .SpecialtyButtons:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                //need a none button, so it gives users the option to not have it.
                createStackViewTagButtons(title, addNoneButton: true)
            case .SpecialtySingleSlider:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                createDistanceSliderView()
            case .SpecialtyRangeSlider:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                createAgeRangeSliderView()
            }
        } else if sender.tag == 2 {
            //the remove button in theChosenTagView was pressed
            changeTagListViewWidth(tagView, extend: false)
        }
        
    }
    
    func createStackViewTagButtonsAndSpecialtyEnviroment(categoryTitleText: String) {
        createSpecialtyTagEnviroment(false, categoryTitleText: categoryTitleText)
        createStackViewTagButtons(categoryTitleText, addNoneButton: true)
    }
    
    func genericTagIsSpecial(tagTitle: String) {
        for filterName in FilterNames.allValues {
            if filterName.rawValue == tagTitle {
                //we have a specialty generic tag
                if FilterNames.genderAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.Gender.rawValue)
                } else if FilterNames.hairColorAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.HairColor.rawValue)
                } else if FilterNames.sexualityAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.Sexuality.rawValue)
                } else if FilterNames.politicalAffiliationAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.PoliticalAffiliation.rawValue)
                } else if FilterNames.raceAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.Race.rawValue)
                }
            }
        }
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        //do nothing because we only act on tag Remove buttons being pressed
    }
}

extension AddingTagsToProfileViewController: UISearchBarDelegate {
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
