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
    @IBOutlet weak var theDoneButton: UIBarButtonItem!
    
    var addToProfileTagArray : [Tag] = []
    var createdTag : TagView?
    
    @IBAction func theDoneButtonPressed(sender: AnyObject) {
        theActivityIndicator.startAnimating()
        theActivityIndicator.hidden = false
        theDoneButton.enabled = false
        PFObject.saveAllInBackground(addToProfileTagArray) { (success, error) in
            if success {
                self.theActivityIndicator.stopAnimating()
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.theDoneButton.enabled = true
                print(error)
            }
        }
    }
    
    
    @IBAction func addToProfilePressed(sender: UIButton) {
        for tagView in tagChosenView.tagViews {
            if let title = tagView.currentTitle {
                let tag = Tag(title: title)
                addToProfileTagArray.append(tag)
                tagChoicesView.addTag(title)
            }
        }
        tagChosenView.removeAllTags()
        tagChosenViewWidthConstraint.constant = 0
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
    
    override func doneSpecialtyButtonPressed(sender: UIButton) {
        super.doneSpecialtyButtonPressed(sender)
        if sender.titleLabel?.text == createTagButtonText {
            //we re-create the tagView with the original tags and then the created tag is already kept in
            setTagsFromDictionary()
            if let createdTag = createdTag {
                if let title = createdTag.currentTitle {
                    let tag = Tag(title: title)
                    addToProfileTagArray.append(tag)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddingTagsToProfileViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        tagAttributeActions(title, sender: sender, tagPressed: false)
        if sender.tag == 2 {
            //the remove button in theChosenTagView was pressed
            changeTagListViewWidth(tagView, extend: false)
        }
    }
    
    func createStackViewTagButtonsAndSpecialtyEnviroment(categoryTitleText: String) {
        createSpecialtyTagEnviroment(false, categoryTitleText: categoryTitleText)
        createStackViewTagButtons(categoryTitleText, addNoneButton: true)
    }
    
    //creates the special buttons as well as checks if the generic tag is a special one
    func genericTagIsSpecial(tagTitle: String) -> Bool {
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
                //FilterNames contains the tag, so it is a special tag and we return true
                return true
            }
        }
        return false
    }
    
    func tagAttributeActions(title: String, sender: TagListView, tagPressed: Bool) {
        if sender.tag == 1 {
            //we have chosen/removed something from the ChosenTagView
            let tagAttribute = tagDictionary[title]!
            switch tagAttribute {
            case .Generic:
                if !genericTagIsSpecial(title) && tagPressed {
                    //we are dealing with a normal generic tag that was pressed
                    print("hi")
                }
            //TODO: Remove from Parse Backend when the tag is removed or have it all removed once we hit done
            case .SpecialtyButtons:
                createStackViewTagButtonsAndSpecialtyEnviroment(title)
            case .SpecialtySingleSlider:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                createDistanceSliderView()
            case .SpecialtyRangeSlider:
                createSpecialtyTagEnviroment(false, categoryTitleText: title)
                createAgeRangeSliderView()
            }
        }
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        //we only want to have an action for tag pressed if the user taps something in choices tag view
        tagAttributeActions(title, sender: sender, tagPressed: true)
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
        if filtered.isEmpty {
            createSpecialtyTagEnviroment(false, categoryTitleText: "Create A New Tag?")
            createdTag = tagChoicesView.addTag(searchText)
            tagChoicesView.hidden = false
            theDoneSpecialtyButton.setTitle(createTagButtonText, forState: .Normal)
        } else {
            createSpecialtyTagEnviroment(true, categoryTitleText: nil)
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
