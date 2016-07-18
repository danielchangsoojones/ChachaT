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
    @IBOutlet weak var theYourTagsLabel: UILabel!
    
    var createdTag : TagView?
    var alreadySavedTags = false
    
    @IBAction func theDoneButtonPressed(sender: AnyObject) {
        theActivityIndicator.startAnimating()
        theActivityIndicator.hidden = false
        theDoneButton.enabled = false
        PFObject.saveAllInBackground(chosenTagArray) { (success, error) in
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
                //checking to see if the attribute is special
                let attribute : TagAttributes = findFilterNameCategory(title) != nil ? .SpecialtyButtons : .Generic
                let tag = Tag(title: title, attribute: attribute)
                chosenTagArray.append(tag)
                tagChoicesView.addTag(title)
            }
        }
        tagChosenView.removeAllTags()
        tagChosenViewWidthConstraint.constant = 0
    }
    
    override func addToProfileTagArray(title: String) {
        let newTag = Tag(title: title, attribute: .Generic)
        chosenTagArray.append(newTag)
        self.currentUserTags.append(newTag)
        resetTagChoicesViewList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTagsInCurrentUserArray()
        changeTheChoicesTagView()
        tagChoicesView.delegate = self
        tagChosenView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        //the alertview, the first time I clicked a tag, was not loading quickly. But, subsequent alerts were loading
        //quickly, so I added this to already load a SCLAlertView, so then when a tag is hit, it loads quickly
        //this actually seems to make it work. But, maybe it is just an illusion to me...
        let _ = SCLAlertView()
    }
    
    func setTagsInCurrentUserArray() {
        let query = Tag.query()
        if let currentUser = User.currentUser() {
                query?.whereKey("createdBy", equalTo: currentUser)
                query?.findObjectsInBackgroundWithBlock({ (objects, error) in
                    if error == nil {
                        if let tags = objects as? [Tag] {
                            for tag in tags {
                                self.currentUserTags.append(tag)
                            }
                            self.setSpecialtyTagsInArray(self.currentUserTags)
                            self.loadData()
                        }
                    } else {
                        print(error)
                    }
                })
        }
    }
    
//  Purpose: this adds specialty tags to the array, as long as the user does not already have them.
    //For Example: If user already has Race: Black, then no need to create specialty tag
    func setSpecialtyTagsInArray(tagArray: [Tag]) {
        //this array is to hold any specialtyTags that the user has already set, hence, we do not need to set a defualt blank one
        var alreadyCreatedSpecialtyTagArray : [SpecialtyTags] = []
        for tag in tagArray where tag.attribute == TagAttributes.SpecialtyButtons.rawValue {
            //checking for tags with a specialty and adding to array
            if let filterNameCategory = findFilterNameCategory(tag.title) {
                alreadyCreatedSpecialtyTagArray.append(filterNameCategory)
            }
        }
        for specialtyButtonTag in SpecialtyTags.specialtyButtonValues {
            if !alreadyCreatedSpecialtyTagArray.contains(specialtyButtonTag) {
                //the users default tags do not already contain a specialty tag, so we want to create a generic one
                //For Example: "Hair Color: None"
                let tagTitle = specialtyButtonTag.rawValue + ": ?"
                self.currentUserTags.append(Tag(title: tagTitle, attribute: .SpecialtyButtons))
            }
        }
        for specialtySingleSliderTag in SpecialtyTags.specialtySingleSliderValues {
            self.currentUserTags.append(Tag(title: specialtySingleSliderTag.rawValue, attribute: .SpecialtySingleSlider))
        }
        for specialtyRangeSliderTag in SpecialtyTags.specialtyRangeSliderValues {
            self.currentUserTags.append(Tag(title: specialtyRangeSliderTag.rawValue, attribute: .SpecialtyRangeSlider))
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
        var existsInChoicesTagView = false
        for tag in currentUserTags where tag.title == tagTitle {
            existsInChoicesTagView = true
        }
        return (tagExistsInChosenTagListView(tagChosenView, title: tagTitle) || existsInChoicesTagView)
    }
    
    override func removeChoicesTag(tagTitle: String) {
        super.removeChoicesTag(tagTitle)
        for tag in currentUserTags where tag.title == tagTitle {
            //TODO: Not sure if I should change this to delete with block since, I should probably
            //check if the tag was really deleted before the user leaves the page
            tag.deleteInBackground()
        }
    }
}

extension AddingTagsToProfileViewController {
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
        //not a special generic tag, so just treat like a normal tag
        return false
    }
    
    func tagAttributeActions(title: String, sender: TagListView, tagPressed: Bool, tagView: TagView) {
        if sender.tag == 1 {
            //we have chosen/removed something from the ChosenTagView
            for tag in currentUserTags where tag.title == title {
                    switch tag.attribute {
                    case TagAttributes.Generic.rawValue:
                        if !genericTagIsSpecial(title) && tagPressed {
                            //we are dealing with a normal generic tag that was pressed
                            createEditingTextFieldPopUp(title, tagView: tagView)
                        }
                    //TODO: Remove from Parse Backend when the tag is removed or have it all removed once we hit done
                    case TagAttributes.SpecialtyButtons.rawValue:
                        //taking the tag title and searching what specialty category it belongs to Gender, Race, ect.
                        //then, I pass the category to the stack view, so it can create that respective stack view. 
                        if let specialtyTagCategory = findFilterNameCategory(title)?.rawValue {
                            createStackViewTagButtonsAndSpecialtyEnviroment(specialtyTagCategory, pushOneButton: true)
                        } else if let _ = SpecialtyTags(rawValue: title) {
                            //if the method is passed just "Hair Color", which would happen if the user has not inputed their hair color, then we don't want to find filterCategory Name
                            //we just want to create stack view with the title given, Hence:
                            createStackViewTagButtonsAndSpecialtyEnviroment(title, pushOneButton: true)
                        }
                    case TagAttributes.SpecialtySingleSlider.rawValue:
                        theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .DistanceSlider)
                        createSpecialtyTagEnviroment(false)
                    case TagAttributes.SpecialtyRangeSlider.rawValue:
                        theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .AgeRangeSlider)
                        createSpecialtyTagEnviroment(false)
                    default:
                        break
                    }
            }
            theSpecialtyTagEnviromentHolderView?.delegate = self
        }
    }
    //Do not need to refactor code below
    //Purpose: I want an editing SCLAlertView, with a textfield, to appear when the user taps a generic tag
    func createEditingTextFieldPopUp(originalTagText: String, tagView: TagView) {
        let alert = SCLAlertView()
        let textField = alert.addTextField()
        textField.text = originalTagText
        alert.addButton("Done") {
            if let editedTagText = textField.text {
                tagView.setTitle(editedTagText, forState: .Normal)
                let newTag = Tag(title: editedTagText, attribute: .Generic)
                self.currentUserTags.append(newTag)
                for tag in self.currentUserTags where tag.title == originalTagText {
                    //delete element in array
                    self.currentUserTags.removeAtIndex(self.currentUserTags.indexOf(tag)!)
                    //remove the previous tag from the actual backend
                    //TODO: this will be done, without the user knowing if the removal was actually completed. Probably should change that. My other stuff is saving when I hit the done button, so I should also delete when the done button is hit.
                    tag.deleteInBackground()
                }
                //deleting the tag from addToProfileTagArray, so it doesn't save the original text to backend
                self.chosenTagArray = self.chosenTagArray.filter({ (tag) -> Bool in
                     return tag.title != originalTagText
                })
                self.chosenTagArray.append(newTag)
            }
            self.tagChoicesView.layoutSubviews()
        }
        alert.showEdit("Edit The Tag", subTitle: "", closeButtonTitle: "Cancel")
    }
    
    override func createSpecialtyTagEnviroment(specialtyEnviromentHidden: Bool) {
        super.createSpecialtyTagEnviroment(specialtyEnviromentHidden)
        theYourTagsLabel.hidden = !specialtyEnviromentHidden
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        //we only want to have an action for tag pressed if the user taps something in choices tag view
        //the tag from the choices tag view was pressed
        //in storyboard, we made the tag for choices tag view = 1
        if sender.tag == 1 {
            if searchActive {
                //we are in the process of searching, so we are dealing with the choices tag view still, but we want searching functionality
                changeTagListViewWidth(tagView, extend: true)
                self.tagChoicesView.removeTag(title)
                if !tagExistsInChosenTagListView(tagChosenView, title: title) {
                    //TODO: do something to let the user know that they have already inputed this tag, so no need to do it again. This should probably be added somewhere in tag view class.
                    self.tagChosenView.addTag(title)
                }
            } else {
                //we are dealing with the choices tag view still, but want default user tag functionality like editing tags, ect. because we are not in search mode
                let tagTitleWithRemovedSpecialtyPrefix = removeSpecialtyPrefixString(title)
                tagAttributeActions(tagTitleWithRemovedSpecialtyPrefix, sender: sender, tagPressed: true, tagView: tagView)
            }
        }
    }
    
    //Purpose: Tags have different functionality, so we need a switch statement to deal with all the different types
    //For Example: If the distance tag is pressed, then the tag displays a single button slider
    func tagPressedAttributeActions(title: String, tagView: TagView) {
        for tag in currentUserTags where tag.title == title {
            switch tag.attribute {
            case TagAttributes.Generic.rawValue:
                createEditingTextFieldPopUp(title, tagView: tagView)
            case TagAttributes.SpecialtyButtons.rawValue:
                //taking the tag title and searching what specialty category it belongs to Gender, Race, ect.
                //then, I pass the category to the stack view, so it can create that respective stack view.
                if let specialtyTagCategory = findFilterNameCategory(title)?.rawValue {
                    createStackViewTagButtonsAndSpecialtyEnviroment(specialtyTagCategory, pushOneButton: true)
                } else if let _ = SpecialtyTags(rawValue: title) {
                    //if the method is passed just "Hair Color", which would happen if the user has not inputed their hair color, then we don't want to find filterCategory Name
                    //we just want to create stack view with the title given, Hence:
                    createStackViewTagButtonsAndSpecialtyEnviroment(title, pushOneButton: true)
                }
            case TagAttributes.SpecialtySingleSlider.rawValue:
                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .DistanceSlider)
                createSpecialtyTagEnviroment(false)
            case TagAttributes.SpecialtyRangeSlider.rawValue:
                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .AgeRangeSlider)
                createSpecialtyTagEnviroment(false)
            default:
                //should never reach here
                break
            }
        }
        theSpecialtyTagEnviromentHolderView?.delegate = self
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
        searchBar.resignFirstResponder()
        resetTagChoicesViewList()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.showsCancelButton = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var filtered:[Tag] = []
        tagChoicesView.removeAllTags()
        filtered = allParseTags.filter({ (tag) -> Bool in
            let tmp: NSString = tag.title
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if searchText.isEmpty {
            //no text, so we want to stay on the tagChoicesView
            searchActive = false
            resetTagChoicesViewList()
        } else if(filtered.count == 0){
            //there is text, but it has no matches in the database
            searchActive = true
            if !(theSpecialtyTagEnviromentHolderView?.theSpecialtyView is TagListView) {
                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .CreateNewTag)
                theSpecialtyTagEnviromentHolderView?.delegate = self
            }
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
        theYourTagsLabel.hidden = searchActive
    }
    
    func resetTagChoicesViewList() {
        tagChoicesView.removeAllTags()
        for tag in currentUserTags {
            tagChoicesView.addTag(tag.title)
        }
        createSpecialtyTagEnviroment(true)
        theSpecialtyTagEnviromentHolderView?.removeFromSuperview()
    }
}

extension AddingTagsToProfileViewController: MagicMoveable {
    var isMagic: Bool {
        return true
    }
    
    var duration: NSTimeInterval {
        return 0.5
    }
    
    var spring: CGFloat {
        return 0.7
    }
    
    var magicViews: [UIView] {
        return [tagChoicesView]
    }
}
