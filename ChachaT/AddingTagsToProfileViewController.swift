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
import SCLAlertView

class AddingTagsToProfileViewController: FilterTagViewController {
    
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var theAddToProfileButton: UIButton!
    @IBOutlet weak var theDoneButton: UIBarButtonItem!
    
    var addToProfileTagArray : [Tag] = []
    var createdTag : TagView?
    var alreadySavedTags = false
    var tagsFromParse: [Tag] = []
    
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
    
    override func setTagsInTagDictionary() {
        let query = Tag.query()
        if let currentUser = User.currentUser() {
                query?.whereKey("createdBy", equalTo: currentUser)
                query?.findObjectsInBackgroundWithBlock({ (objects, error) in
                    if error == nil {
                        if let tags = objects as? [Tag] {
                            //saving tags to this array, so I can delete any tags the user ends up deleting
                            self.tagsFromParse = tags
                            for tag in tags {
                                self.tagDictionary[tag.title] = .Generic
                                
                            }
                            self.loadData()
                        }
                    } else {
                        print(error)
                    }
                })
        }
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

//overrided super class methods
extension AddingTagsToProfileViewController {
    
    //overriding this because we want to have a special case for creating a new tag within user editing mode
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
    
    //overriding this method because I want to not only see if tag exists with chosen tags
    //we also want to see if tag is in the already saved Parse tags because then the button
    //should be highlighted.
    override func doesChosenTagViewContain(tagTitle: String) -> Bool {
        let existsInChoicesTagDictionary = tagDictionary[tagTitle] != nil
        return (tagExistsInChosenTagListView(tagChosenView, title: tagTitle) || existsInChoicesTagDictionary)
    }
    
    override func removeChoicesTag(tagTitle: String) {
        super.removeChoicesTag(tagTitle)
        for tag in tagsFromParse where tag.title == tagTitle {
            //TODO: Not sure if I should change this to delete with block since, I should probably
            //check if the tag was really deleted before the user leaves the page
            tag.deleteInBackground()
        }
    }
    
}

extension AddingTagsToProfileViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        tagAttributeActions(title, sender: sender, tagPressed: false)
        if sender.tag == 2 {
            //the remove button in theChosenTagView was pressed
            changeTagListViewWidth(tagView, extend: false)
        } else if sender.tag == 1{
            //we hit the remove button in theChoicesTagView
            removeChoicesTag(title)
        }
    }
    
    func createStackViewTagButtonsAndSpecialtyEnviroment(categoryTitleText: String) {
        theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(filterCategory: categoryTitleText, addNoneButton: true, stackViewButtonDelegate: self)
        createSpecialtyTagEnviroment(false)
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
            if let tagAttribute = tagDictionary[title] {
            switch tagAttribute {
            case .Generic:
                if !genericTagIsSpecial(title) && tagPressed {
                    //we are dealing with a normal generic tag that was pressed
                    print("hi")
                    createAlertTextFieldPopUp(title)
                }
            //TODO: Remove from Parse Backend when the tag is removed or have it all removed once we hit done
            case .SpecialtyButtons:
                createStackViewTagButtonsAndSpecialtyEnviroment(title)
            case .SpecialtySingleSlider:
                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .DistanceSlider)
                createSpecialtyTagEnviroment(false)
            case .SpecialtyRangeSlider:
                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .AgeRangeSlider)
                createSpecialtyTagEnviroment(false)
                }
            }
            theSpecialtyTagEnviromentHolderView?.delegate = self
        }
    }
    
    func createAlertTextFieldPopUp(text: String) {
        let alert = SCLAlertView()
        let textField = alert.addTextField()
        textField.text = text
        alert.showEdit("Edit The Tag", subTitle: "")
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
            createSpecialtyTagEnviroment(false)
            createdTag = tagChoicesView.addTag(searchText)
            tagChoicesView.hidden = false
            theSpecialtyTagEnviromentHolderView?.theDoneButton.setTitle(createTagButtonText, forState: .Normal)
        } else {
            searchActive = true
            for tag in filtered {
                tagChoicesView.addTag(tag)
            }
            createSpecialtyTagEnviroment(true)
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
