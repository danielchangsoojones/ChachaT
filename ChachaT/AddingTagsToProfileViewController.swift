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
    @IBOutlet weak var theDoneButton: UIBarButtonItem!
    
    var alreadySavedTags = false
    let questionMarkString = "?"
    var dataStore : AddingTagsDataStore!

    
    @IBAction func theDoneButtonPressed(sender: AnyObject) {
//        theActivityIndicator.startAnimating()
//        theActivityIndicator.hidden = false
//        theDoneButton.enabled = false
//        PFObject.saveAllInBackground(chosenTagArray) { (success, error) in
//            if success {
//                self.theActivityIndicator.stopAnimating()
//                self.navigationController?.popViewControllerAnimated(true)
//            } else {
//                self.theDoneButton.enabled = true
//                print(error)
//            }
//        }
    }
    
    @IBAction func addToProfilePressed(sender: UIButton) {
//        for tagView in tagChosenView.tagViews {
//            if let title = tagView.currentTitle {
//                let tag = createNewTag(title)
//                chosenTagArray.append(tag)
//                self.tagChoicesDataArray.append(tag)
//                addTagOrSpecialtyTag(tag, addToChosenView: false)
//            }
//        }
//        tagChosenView.removeAllTags()
//        tagChosenViewWidthConstraint.constant = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagChoicesView.delegate = self
        tagChoicesView.addTag("banana")
        setDataFromDataStore()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        //the alertview, the first time I clicked a tag, was not loading quickly. But, subsequent alerts were loading
        //quickly, so I added this to already load a SCLAlertView, so then when a tag is hit, it loads quickly
        //this actually seems to make it work. But, maybe it is just an illusion to me...
        let _ = SCLAlertView()
    }
    
    func setDataFromDataStore() {
        dataStore = AddingTagsDataStore(delegate: self) //sets the data for the tag arrays
    }
    
    override func loadChoicesViewTags() {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//tag methods extension
extension AddingTagsToProfileViewController {
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        //we only want to have an action for tag pressed if the user taps something in choices tag view
        //the tag from the choices tag view was pressed
        //in storyboard, we made the tag for choices tag view = 1 and only generic tag was pressed
        if sender.tag == 1 {
            let alertView = SCLAlertView()
            alertView.addButton("Delete") {
                print("Deleted Tag")
                self.dataStore.deleteTag(title)
            }
            alertView.showError("Delete", subTitle: "Do you want to delete this tag?", closeButtonTitle: "Cancel")
        }
    }
    
    //Purpose: Tags have different functionality, so we need a switch statement to deal with all the different types
    //For Example: If the distance tag is pressed, then the tag displays a single button slider
    func tagPressedAttributeActions(title: String, tagView: TagView) {
//        if let tag = findTag(tagView, tagArray: tagChoicesDataArray) {
//            switch tag.attribute {
//            case TagAttributes.Generic.rawValue:
//                createEditingTextFieldPopUp(title, originalTagView: tagView)
//            case TagAttributes.SpecialtyTagMenu.rawValue: break
//                //checking if we just got passed something like Black or Blonde, because then we need to convert it to a specialty tag category
//                //but if not, then we just need to pass the title because it is already a specialty tag category
////                if let specialtyTagView = tagView as? SpecialtyTagView {
////                    createStackViewTagButtonsAndSpecialtyEnviroment(specialtyTagView.specialtyTagTitle, pushOneButton: true, addNoneButton: true)
////                }
//            case TagAttributes.SpecialtySingleSlider.rawValue:
//                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .DistanceSlider)
//                createSpecialtyTagEnviroment(true)
//            case TagAttributes.SpecialtyRangeSlider.rawValue:
//                //birthday picker here because we don't want an age range slider, we want to know how old the user is
//                createBirthdayDatePickerPop()
//            default:
//                //should never reach here, just had to implement because tagAttribute is string, not enum, because I needed to save it in Parse as Enum
//                break
//            }
//        }
//        theSpecialtyTagEnviromentHolderView?.delegate = self
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
//                if specialtyTagView.specialtyTagTitle == "Age" {
//                    tagView.setTitle("\(ageComponents.year)", forState: .Normal)
//                }
            }
            User.currentUser()!.birthDate = birthday
            //TODO: I probably should be doing something to make sure this actually saves, in case they exit the app very fast before it saves.
            User.currentUser()!.saveInBackground()
        }
    }
}

//search extension
extension AddingTagsToProfileViewController {
    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var filtered:[String] = []
        tagChoicesView.removeAllTags()
        filtered = searchDataArray.filter({ (tagTitle) -> Bool in
            let tmp: NSString = tagTitle
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
        } else {
            //there is text, and we have a match, so the tagChoicesView changes accordingly
            searchActive = true
        }
    }
}
