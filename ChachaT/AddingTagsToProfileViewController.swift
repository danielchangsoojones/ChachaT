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
    var currentUserTags: [Tag] = []
    var allParseTags: [Tag] = []
    
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
        setDataArray()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        //the alertview, the first time I clicked a tag, was not loading quickly. But, subsequent alerts were loading
        //quickly, so I added this to already load a SCLAlertView, so then when a tag is hit, it loads quickly
        //this actually seems to make it work. But, maybe it is just an illusion to me...
        let _ = SCLAlertView()
    }
    
    override func setTagsInTagDictionary() {
        let query = Tag.query()
        if let currentUser = User.currentUser() {
                query?.whereKey("createdBy", equalTo: currentUser)
                query?.findObjectsInBackgroundWithBlock({ (objects, error) in
                    if error == nil {
                        if let tags = objects as? [Tag] {
                            //saving tags to this array, so I can delete any tags the user ends up deleting
                            self.currentUserTags = tags
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
    
    //overriding this method because I want to not only see if tag exists with chosen tags
    //we also want to see if tag is in the already saved Parse tags because then the button
    //should be highlighted.
    override func doesChosenTagViewContain(tagTitle: String) -> Bool {
        let existsInChoicesTagDictionary = tagDictionary[tagTitle] != nil
        return (tagExistsInChosenTagListView(tagChosenView, title: tagTitle) || existsInChoicesTagDictionary)
    }
    
    override func removeChoicesTag(tagTitle: String) {
        super.removeChoicesTag(tagTitle)
        for tag in currentUserTags where tag.title == tagTitle {
            //TODO: Not sure if I should change this to delete with block since, I should probably
            //check if the tag was really deleted before the user leaves the page
            tag.deleteInBackground()
        }
    }
    
    override func addToProfileTagArray(title: String) {
        addToProfileTagArray.append(Tag(title: title))
        tagDictionary[title] = .Generic
        resetTagChoicesViewList()
    }
}

extension AddingTagsToProfileViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        tagAttributeActions(title, sender: sender, tagPressed: false, tagView: tagView)
        if sender.tag == 2 {
            //the remove button in theChosenTagView was pressed
            changeTagListViewWidth(tagView, extend: false)
        } else if sender.tag == 1{
            //we hit the remove button in theChoicesTagView
            removeChoicesTag(title)
        }
    }
    
    func createStackViewTagButtonsAndSpecialtyEnviroment(categoryTitleText: String, pushOneButton: Bool) {
        theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(filterCategory: categoryTitleText, addNoneButton: true, stackViewButtonDelegate: self, pushOneButton: pushOneButton)
        createSpecialtyTagEnviroment(false)
    }
    
    //creates the special buttons as well as checks if the generic tag is a special one
    func genericTagIsSpecial(tagTitle: String) -> Bool {
        for filterName in FilterNames.allValues {
            if filterName.rawValue == tagTitle {
                //we have a specialty generic tag
                if FilterNames.genderAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.Gender.rawValue, pushOneButton: true)
                } else if FilterNames.hairColorAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.HairColor.rawValue, pushOneButton: true)
                } else if FilterNames.sexualityAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.Sexuality.rawValue, pushOneButton: true)
                } else if FilterNames.politicalAffiliationAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.PoliticalAffiliation.rawValue, pushOneButton: true)
                } else if FilterNames.raceAllValues.contains(filterName) {
                    createStackViewTagButtonsAndSpecialtyEnviroment(SpecialtyTags.Race.rawValue, pushOneButton: true)
                }
                //FilterNames contains the tag, so it is a special tag and we return true
                return true
            }
        }
        return false
    }
    
    func tagAttributeActions(title: String, sender: TagListView, tagPressed: Bool, tagView: TagView) {
        if sender.tag == 1 {
            //we have chosen/removed something from the ChosenTagView
            if let tagAttribute = tagDictionary[title] {
            switch tagAttribute {
            case .Generic:
                if !genericTagIsSpecial(title) && tagPressed {
                    //we are dealing with a normal generic tag that was pressed
                    createAlertTextFieldPopUp(title, tagView: tagView)
                }
            //TODO: Remove from Parse Backend when the tag is removed or have it all removed once we hit done
            case .SpecialtyButtons:
                createStackViewTagButtonsAndSpecialtyEnviroment(title, pushOneButton: true)
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
    
    func createAlertTextFieldPopUp(originalTagText: String, tagView: TagView) {
        let alert = SCLAlertView()
        let textField = alert.addTextField()
        textField.text = originalTagText
        alert.addButton("Done") {
            if let editedTagText = textField.text {
                tagView.setTitle(editedTagText, forState: .Normal)
                self.tagDictionary[editedTagText] = .Generic
                self.tagDictionary.removeValueForKey(originalTagText)
                //deleting the tag from addToProfileTagArray, so it doesn't save the original text to backend
                self.addToProfileTagArray = self.addToProfileTagArray.filter({ (tag) -> Bool in
                     return tag.title != originalTagText
                })
                self.addToProfileTagArray.append(Tag(title: editedTagText))
                print(self.addToProfileTagArray)
            }
            self.tagChoicesView.layoutSubviews()
        }
        alert.showEdit("Edit The Tag", subTitle: "", closeButtonTitle: "Cancel")
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        //we only want to have an action for tag pressed if the user taps something in choices tag view
        tagAttributeActions(title, sender: sender, tagPressed: true, tagView: tagView)
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
        resetTagChoicesViewList()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.showsCancelButton = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(allParseTags)
        var filtered:[Tag] = []
        tagChoicesView.removeAllTags()
        filtered = allParseTags.filter({ (tag) -> Bool in
            let tmp: NSString = tag.title
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if searchText == "" {
            //no text, so we want to stay on the tagChoicesView
            resetTagChoicesViewList()
        } else if(filtered.count == 0){
            //there is text, but it has no matches in the database
            if !(theSpecialtyTagEnviromentHolderView?.theSpecialtyView is TagListView) {
                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .CreateNewTag)
                theSpecialtyTagEnviromentHolderView?.delegate = self
            }
            searchActive = false
            createSpecialtyTagEnviroment(false)
            theSpecialtyTagEnviromentHolderView?.updateTagListView(searchText)
            theSpecialtyTagEnviromentHolderView?.setButtonText("Create")
        } else {
            //there is text, and we have a match, so the tagChoicesView changes accordingly
            searchActive = true
            for tag in filtered {
                tagChoicesView.addTag(tag.title)
            }
            createSpecialtyTagEnviroment(true)
        }
    }
    
    //TODO; right now, my search is pulling down the entire tag table and then doing search, 
    //very ineffecient, and in future, I will have to do server side cloud code.
    func setDataArray() {
        let query = PFQuery(className: "Tag")
        query.selectKeys(["title"])
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                for tag in tags {
//                    for dataTags in dataArray where dataTags.title != tag.title {
//                        //the dataArray does not already have a tag title like this yet,
//                        //so, we need to add it to the array
                    self.allParseTags.append(tag)
                    print(self.allParseTags)
//                    }
                }
            }
        }
    }
    
    func resetTagChoicesViewList() {
        for (tagTitle, _) in tagDictionary {
            tagChoicesView.addTag(tagTitle)
        }
        createSpecialtyTagEnviroment(true)
        theSpecialtyTagEnviromentHolderView?.removeFromSuperview()
    }
}
