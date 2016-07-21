//
//  AddingTagsToProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class AddingTagsToProfileViewController: FilterTagViewController {
    
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var theAddToProfileButton: UIButton!
    @IBOutlet weak var theDoneButton: UIBarButtonItem!
    @IBOutlet weak var theYourTagsLabel: UILabel!
    
    var createdTag : TagView?
    var alreadySavedTags = false
    let questionMarkString = "?"
    
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
                let tag = createNewTag(title)
                chosenTagArray.append(tag)
                self.currentUserTags.append(tag)
                addTagOrSpecialtyTag(title, addToChosenView: false)
            }
        }
        tagChosenView.removeAllTags()
        tagChosenViewWidthConstraint.constant = 0
    }
    
    //TODO: change this code to actually deal with specialty Tags? Maybe, maybe it doesn't have to do that.
    override func addToProfileTagArray(title: String) {
        let newTag = createNewTag(title)
        chosenTagArray.append(newTag)
        self.currentUserTags.append(newTag)
        resetTagChoicesViewList()
    }
    
    func createNewTag(title: String) -> Tag {
        let attribute : TagAttributes = findFilterNameCategory(title) != nil ? .SpecialtyButtons : .Generic
        let specialtyTagCategory = findFilterNameCategory(title)
        return Tag(title: title, attribute: attribute, specialtyCategoryTitle: specialtyTagCategory)
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
                            self.setSpecialtyTagsInArray()
                            self.loadChoicesViewTags()
                        }
                    } else {
                        print(error)
                    }
                })
        }
    }
    
    func loadChoicesViewTags() {
        for tag in currentUserTags {
            switch tag.attribute {
            case TagAttributes.Generic.rawValue:
                tagChoicesView.addTag(tag.title)
            case TagAttributes.SpecialtyButtons.rawValue:
                if tag.title == "None" {
                    tagChoicesView.addSpecialtyTag(tag.title, specialtyTagTitle: tag.specialtyCategoryTitle!)
                } else if let specialtyTitle = findFilterNameCategory(tag.title)?.rawValue {
                    //we were passed a value like "Black", which is part of the race category, so we make "Black" the title tag, and "Race" the specialty tag
                    tagChoicesView.addSpecialtyTag(tag.title, specialtyTagTitle: specialtyTitle)
                } else {
                    //it is unknown specialty tag only if the alreadyCreatedSpecialtyTagArray does not contain it. Hence, we have to create a tag like "Hair Color: ?"
                    tagChoicesView.addSpecialtyTag(questionMarkString, specialtyTagTitle: tag.title)
                }
            case TagAttributes.SpecialtySingleSlider.rawValue:
                let currentUser = User.currentUser()
                if let age = currentUser?.calculateBirthDate() {
                    //we know the users current bday, so we make something like "Age: 19"
                    tagChoicesView.addSpecialtyTag(String(age), specialtyTagTitle: "Age")
                } else {
                    tagChoicesView.addSpecialtyTag(questionMarkString, specialtyTagTitle: "Age")
                }
            default: break
            }
        }
    }
    
    //Purpose: this adds specialty tags to the array, as long as the user does not already have them.
    //For Example: If user already has Race: Black, then no need to create specialty tag
    func setSpecialtyTagsInArray() {
        //this array is to hold any specialtyTags that the user has already set, hence, we do not need to set a defualt blank one
        var alreadyCreatedSpecialtyTagArray : [SpecialtyTags] = []
        for tag in currentUserTags where tag.attribute == TagAttributes.SpecialtyButtons.rawValue {
            if let specialtyCategoryName = tag.specialtyCategoryTitle {
                if let specialtyTag = SpecialtyTags(rawValue: specialtyCategoryName) {
                    //checking for tags with a specialty and adding to array
                    alreadyCreatedSpecialtyTagArray.append(specialtyTag)
                }
            }
        }
        print(alreadyCreatedSpecialtyTagArray)
        for specialtyButtonTag in SpecialtyTags.specialtyButtonValues {
            if !alreadyCreatedSpecialtyTagArray.contains(specialtyButtonTag) {
                //the users default tags do not already contain a specialty tag, so we want to create a generic one
                //For Example: "Hair Color: ?"
                self.currentUserTags.append(Tag(title: specialtyButtonTag.rawValue, attribute: .SpecialtyButtons, specialtyCategoryTitle: specialtyButtonTag))
            }
        }
        for specialtySingleSliderTag in SpecialtyTags.specialtySingleSliderValues {
            self.currentUserTags.append(Tag(title: specialtySingleSliderTag.rawValue, attribute: .SpecialtySingleSlider, specialtyCategoryTitle: specialtySingleSliderTag))
        }
        for specialtyRangeSlider in SpecialtyTags.specialtyRangeSliderValues {
            let age : Int = User.currentUser()!.calculateBirthDate()!
            self.currentUserTags.append(Tag(title: String(age), attribute: .SpecialtyRangeSlider, specialtyCategoryTitle: specialtyRangeSlider))
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
        if sender.tag == 2 {
            //the remove button in theChosenTagView was pressed
            changeTagListViewWidth(tagView, extend: false)
        } else if sender.tag == 1{
            //we hit the remove button in theChoicesTagView
            //TODO: if the tag is a specialty tag, then it should not be deleted, but replaced with a "(specialty tag name): ?"
            //For Example: "Hair Color: ?"
        }
    }
    
    //Do not need to refactor code below
    
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
                    addTagOrSpecialtyTag(title, addToChosenView: true)
                }
            } else {
                //we are dealing with the choices tag view still, but want default user tag functionality like editing tags, ect. because we are not in search mode
                tagPressedAttributeActions(setCorrectTitle(title, tagView: tagView), tagView: tagView)
            }
        }
    }
    
    //Purpose: the title might be a category name, "?", or just a generic name, so I need to create the correct title
    func setCorrectTitle(title: String, tagView: TagView) -> String {
    if title == questionMarkString {
            //the tag that was pressed was something like this "Hair Color: ?"
            if let specialtyTagView = tagView as? SpecialtyTagView {
                return specialtyTagView.specialtyTagTitle
            }
        }
        return title
    }
    
    //Purpose: Tags have different functionality, so we need a switch statement to deal with all the different types
    //For Example: If the distance tag is pressed, then the tag displays a single button slider
    func tagPressedAttributeActions(title: String, tagView: TagView) {
        //using or statement because if the user was passed a number, then it is the age number, and we still want to proceed with going to the tag attribute
        for tag in currentUserTags where tag.title == title {
            switch tag.attribute {
            case TagAttributes.Generic.rawValue:
                createEditingTextFieldPopUp(title, tagView: tagView)
            case TagAttributes.SpecialtyButtons.rawValue:
                //checking if we just got passed something like Black or Blonde, because then we need to convert it to a specialty tag category
                //but if not, then we just need to pass the title because it is already a specialty tag category
                createStackViewTagButtonsAndSpecialtyEnviroment(findFilterNameCategory(title)?.rawValue ?? title, pushOneButton: true)
            case TagAttributes.SpecialtySingleSlider.rawValue:
                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .DistanceSlider)
                createSpecialtyTagEnviroment(false)
            case TagAttributes.SpecialtyRangeSlider.rawValue:
                createBirthdayDatePickerPop()
            default:
                //should never reach here
                break
            }
        }
        theSpecialtyTagEnviromentHolderView?.delegate = self
    }
    
    func addTagOrSpecialtyTag(tagTitle: String, addToChosenView: Bool) {
        if let specialtyTagCategory = findFilterNameCategory(tagTitle) {
            //we have a specialty tag, so we want it to look special
            if addToChosenView {
                tagChosenView.addSpecialtyTag(tagTitle, specialtyTagTitle: specialtyTagCategory.rawValue)
            } else {
                tagChoicesView.addSpecialtyTag(tagTitle, specialtyTagTitle: specialtyTagCategory.rawValue)
            }
        } else {
            //we are just dealing with a generic tag
            tagChoicesView.addTag(tagTitle)
        }
    }
    
    func createBirthdayDatePickerPop() {
        DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (birthday) -> Void in
            let calendar : NSCalendar = NSCalendar.currentCalendar()
            let now = NSDate()
            let ageComponents = calendar.components(.Year,
                    fromDate: birthday,
                    toDate: now,
                    options: [])
            for tagView in self.tagChoicesView.tagViews where tagView is SpecialtyTagView {
                let specialtyTagView = tagView as! SpecialtyTagView
                if specialtyTagView.specialtyTagTitle == "Age" {
                    tagView.setTitle("\(ageComponents.year)", forState: .Normal)
                }
            }
            User.currentUser()!.birthDate = birthday
            //TODO: I probably should be doing something to make sure this actually saves, in case they exit the app very fast before it saves.
            User.currentUser()!.saveInBackground()
            }
    }
    
    //Purpose: I want an editing SCLAlertView, with a textfield, to appear when the user taps a generic tag
    func createEditingTextFieldPopUp(originalTagText: String, tagView: TagView) {
        let alert = SCLAlertView()
        let textField = alert.addTextField()
        textField.text = originalTagText
        alert.addButton("Done") {
            if let editedTagText = textField.text {
                tagView.setTitle(editedTagText, forState: .Normal)
                let newTag = Tag(title: editedTagText, attribute: .Generic, specialtyCategoryTitle: nil)
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
            theSpecialtyTagEnviromentHolderView?.setButtonText("Create New Tag?")
        } else {
            //there is text, and we have a match, so the tagChoicesView changes accordingly
            searchActive = true
            for tag in filtered {
                addTagOrSpecialtyTag(tag.title, addToChosenView: false)
            }
            createSpecialtyTagEnviroment(true)
        }
        theYourTagsLabel.hidden = searchActive
    }
    
    func resetTagChoicesViewList() {
        tagChoicesView.removeAllTags()
        loadChoicesViewTags()
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
