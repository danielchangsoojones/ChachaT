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
                self.tagChoicesDataArray.append(tag)
                addTagOrSpecialtyTag(tag, addToChosenView: false)
            }
        }
        tagChosenView.removeAllTags()
        tagChosenViewWidthConstraint.constant = 0
    }
    
    //TODO: change this code to actually deal with specialty Tags? Maybe, maybe it doesn't have to do that.
    override func createNewPersonalTag(title: String) {
        let newTag = createNewTag(title)
        chosenTagArray.append(newTag)
        self.tagChoicesDataArray.append(newTag)
        resetTagChoicesViewList()
    }
    
    func createNewTag(title: String) -> Tag {
        let specialtyTagCategory = findSpecialtyCategoryName(title)
        return Tag(title: title, specialtyCategoryTitle: specialtyTagCategory)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTagsInTagChoicesDataArray()
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
    
    func setTagsInTagChoicesDataArray() {
        let query = Tag.query()
        if let currentUser = User.currentUser() {
                query?.whereKey("createdBy", equalTo: currentUser)
                query?.findObjectsInBackgroundWithBlock({ (objects, error) in
                    if error == nil {
                        if let tags = objects as? [Tag] {
                            for tag in tags {
                                self.tagChoicesDataArray.append(tag)
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
    
    override func loadChoicesViewTags() {
        for tag in tagChoicesDataArray {
            switch tag.attribute {
            case TagAttributes.Generic.rawValue:
                tagChoicesView.addTag(tag.title)
            case TagAttributes.SpecialtyButtons.rawValue:
                if let specialtyCategoryTitle = tag.specialtyCategoryTitle {
                    //should create tag that looks something like Hair Color : Blonde
                    tagChoicesView.addSpecialtyTag(tag.title, specialtyTagTitle: specialtyCategoryTitle)
                }
            case TagAttributes.SpecialtyRangeSlider.rawValue:
                let currentUser = User.currentUser()
                if let age = currentUser?.calculateBirthDate() {
                    //we know the users current bday, so we make something like "Age: 19"
                    tagChoicesView.addSpecialtyTag(String(age), specialtyTagTitle: "Age")
                }
            case TagAttributes.SpecialtySingleSlider.rawValue: break
            default: break
            }
        }
    }

    //Purpose: this adds specialty tags to the array, as long as the user does not already have them.
    //For Example: If user already has Race: Black, then no need to create specialty tag
    func setSpecialtyTagsInArray() {
        var alreadyCreatedSpecialtyTagArray : [SpecialtyTags] = []
        for tag in tagChoicesDataArray where tag.attribute != TagAttributes.Generic.rawValue {
            if let specialtyCategoryName = findSpecialtyCategoryName(tag.title) {
                //this array is to hold any specialtyTags that the user has already set, hence, we do not need to set a defualt one with ?
                alreadyCreatedSpecialtyTagArray.append(specialtyCategoryName)
            }
        }
        for specialtyButtonTag in SpecialtyTags.specialtyButtonValues {
            if !alreadyCreatedSpecialtyTagArray.contains(specialtyButtonTag) {
                //the users default tags do not already contain a specialty tag, so we want to create a generic one
                //For Example: "Hair Color: ?"
                self.tagChoicesDataArray.append(Tag(title: questionMarkString, specialtyCategoryTitle: specialtyButtonTag))
            }
        }
        for specialtySingleSliderTag in SpecialtyTags.specialtySingleSliderValues {
            self.tagChoicesDataArray.append(Tag(title: questionMarkString, specialtyCategoryTitle: specialtySingleSliderTag))
        }
        for specialtyRangeSlider in SpecialtyTags.specialtyRangeSliderValues {
            //user has not inputed birthday, so need Age : ?
            self.tagChoicesDataArray.append(Tag(title: questionMarkString, specialtyCategoryTitle: specialtyRangeSlider))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//tag methods extension
extension AddingTagsToProfileViewController {
    //overriding this method because I want to not only see if tag exists with chosen tags
    //we also want to see if tag is in the already saved Parse tags because then the button
    //should be highlighted.
    override func doesChosenTagViewContain(tagTitle: String) -> Bool {
        let existsInChoicesTagView = findTag(TagView(title: tagTitle), tagArray: tagChoicesDataArray) != nil
        return (tagChosenView.tagExistsInTagListView(tagTitle) || existsInChoicesTagView)
    }
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 2 {
            //the remove button in theChosenTagView was pressed
            sender.removeTagView(tagView)
            changeTagListViewWidth(tagView, extend: false)
        }
    }
    
    override func createSpecialtyTagEnviroment(showSpecialtyEnviroment: Bool) {
        super.createSpecialtyTagEnviroment(showSpecialtyEnviroment)
        theYourTagsLabel.hidden = showSpecialtyEnviroment
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
                //TODO: do something to let the user know that they have already inputed this tag, so no need to do it again. This should probably be added somewhere in tag view class.
                if let tag = findTag(tagView, tagArray: tagChoicesDataArray) {
                    addTagOrSpecialtyTag(tag, addToChosenView: true)
                }
            } else {
                //we are dealing with the choices tag view still, but want default user tag functionality like editing tags, ect. because we are not in search mode
                tagPressedAttributeActions(title, tagView: tagView)
            }
        }
    }
    
    func addTagOrSpecialtyTag(tag: Tag, addToChosenView: Bool) {
        if let specialtyCategoryTitle = tag.specialtyCategoryTitle {
            //the tag is a special tag
            if addToChosenView {
                tagChosenView.addSpecialtyTag(tag.title, specialtyTagTitle: specialtyCategoryTitle)
            } else {
                tagChoicesView.addSpecialtyTag(tag.title, specialtyTagTitle: specialtyCategoryTitle)
            }
        } else {
            //just a generic tag
            if addToChosenView {
                tagChosenView.addTag(tag.title)
            } else {
                tagChoicesView.addTag(tag.title)
            }
        }
    }
    
    //Purpose: Tags have different functionality, so we need a switch statement to deal with all the different types
    //For Example: If the distance tag is pressed, then the tag displays a single button slider
    func tagPressedAttributeActions(title: String, tagView: TagView) {
        if let tag = findTag(tagView, tagArray: tagChoicesDataArray) {
            switch tag.attribute {
            case TagAttributes.Generic.rawValue:
                createEditingTextFieldPopUp(title, originalTagView: tagView)
            case TagAttributes.SpecialtyButtons.rawValue:
                //checking if we just got passed something like Black or Blonde, because then we need to convert it to a specialty tag category
                //but if not, then we just need to pass the title because it is already a specialty tag category
                if let specialtyTagView = tagView as? SpecialtyTagView {
                    createStackViewTagButtonsAndSpecialtyEnviroment(specialtyTagView.specialtyTagTitle, pushOneButton: true, addNoneButton: true)
                }
            case TagAttributes.SpecialtySingleSlider.rawValue:
                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .DistanceSlider)
                createSpecialtyTagEnviroment(true)
            case TagAttributes.SpecialtyRangeSlider.rawValue:
                //birthday picker here because we don't want an age range slider, we want to know how old the user is
                createBirthdayDatePickerPop()
            default:
                //should never reach here, just had to implement because tagAttribute is string, not enum, because I needed to save it in Parse as Enum
                break
            }
        }
        theSpecialtyTagEnviromentHolderView?.delegate = self
    }
}

//pop up extensions
extension AddingTagsToProfileViewController {
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
    func createEditingTextFieldPopUp(originalTagText: String, originalTagView: TagView) {
        let alert = SCLAlertView()
        let textField = alert.addTextField()
        textField.text = originalTagText
        alert.addButton("Done") {
            if let editedTagText = textField.text {
                originalTagView.setTitle(editedTagText, forState: .Normal)
                let newTag = Tag(title: editedTagText, specialtyCategoryTitle: nil)
                let originalTag = self.replaceTag(originalTagView, newTag: newTag, tagArray: &self.tagChoicesDataArray)
                //remove the previous tag from the actual backend
                //TODO: this will be done, without the user knowing if the removal was actually completed. Probably should change that. My other stuff is saving when I hit the done button, so I should also delete when the done button is hit.
                originalTag?.deleteInBackground()
                self.replaceTag(originalTagView, newTag: newTag, tagArray: &self.chosenTagArray)
            }
            self.tagChoicesView.layoutSubviews()
        }
        alert.showEdit("Edit The Tag", subTitle: "", closeButtonTitle: "Cancel")
    }
}

//search extension
extension AddingTagsToProfileViewController {
    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var filtered:[Tag] = []
        tagChoicesView.removeAllTags()
        filtered = searchDataArray.filter({ (tag) -> Bool in
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
            createSpecialtyTagEnviroment(true)
            theSpecialtyTagEnviromentHolderView?.updateTagListView(searchText)
            theSpecialtyTagEnviromentHolderView?.setButtonText("Create New Tag?")
        } else {
            //there is text, and we have a match, so the tagChoicesView changes accordingly
            searchActive = true
            for tag in filtered {
                addTagOrSpecialtyTag(tag, addToChosenView: false)
            }
            createSpecialtyTagEnviroment(false)
        }
        theYourTagsLabel.hidden = searchActive
    }
}
