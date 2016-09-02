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
    var specialtyTagChoicesDataArray : [SpecialtyTagTitles] = [] //specialty tags that get added to the choices tag view. Need to have an int array to differentiate between the None types
    
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!
    var creationMenuView: CreationMenuView!
    
    var dataStore : AddingTagsDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagChoicesView.delegate = self
        setDataFromDataStore()
        setTapGestureToCloseKeyboard()
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
        createCreationTagView()
        for specialtyTagTitle in specialtyTagChoicesDataArray {
            tagChoicesView.addSpecialtyTag(specialtyTagTitle, specialtyCategoryTitle: specialtyTagTitle.associatedSpecialtyCategoryTitle!)
        }
        for tagTitle in tagChoicesDataArray {
            //just a generic tag. Right now, I am only adding specialtyTagCategories (Race, Hair Color) to the default view, but that could change
            tagChoicesView.addTag(tagTitle)
        }
    }
    
    //Purpose: the first tag view needs to be a tag view that says "Add tags..." in a different color, and when the user clicks, they can start typing right there.
    //This should create a drop down menu of all available tags
    func createCreationTagView() {
        let tagView = CreationTagView(textFieldDelegate: self, delegate: self, textFont: tagChoicesView.textFont, paddingX: tagChoicesView.paddingX, paddingY: tagChoicesView.paddingY, borderWidth: tagChoicesView.borderWidth, cornerRadius: tagChoicesView.cornerRadius, tagBackgroundColor: tagChoicesView.tagBackgroundColor)
        //TODO: move this the CreationTagView class
        tagView.borderColor = UIColor.blackColor()
        tagChoicesView.addTagView(tagView)
    }
    
    //Purpose: the user should be able to tap, when keyboard is showing, anywhere to dismiss the keyboard
    //IF YOU EVER HAVE WEIRD GESTURES NOT BEING RECOGNIZED, THIS GESTURE RECOGNIZER IS PROBABLY THE PROBLEM
    func setTapGestureToCloseKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddingTagsToProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddingTagsToProfileViewController.dismissTheKeyboard))
        view.addGestureRecognizer(tap)
        //gesture recognizers usually fucks with tableView SelectAtIndexRow, but setting this property to false allows the tap to pass through to the tableView
        tap.cancelsTouchesInView = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//tag methods extension
extension AddingTagsToProfileViewController {
    //TagListView tags: (tagChoicesView = 1, tagChosenView = 2, dropDownTagView = 3)
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 1 {
            //tagChoicesView pressed
            let alertView = SCLAlertView()
            alertView.addButton("Delete") {
                print("Deleted Tag")
                self.dataStore.deleteTag(title)
            }
            alertView.showError("Delete", subTitle: "Do you want to delete this tag?", closeButtonTitle: "Cancel")
        } else if sender.tag == 3 {
            //ChachaDropDownTagView pressed
            if let specialtyTagView = tagChoicesView.findSpecialtyTagView(dropDownMenu.dropDownMenuCategoryType) {
                tagChoicesView.setTagViewTitle(specialtyTagView, title: title)
                dataStore.saveSpecialtyTag(title)
            }
        }
    }
    
    func specialtyTagPressed(title: String, tagView: SpecialtyTagView, sender: TagListView) {
        let specialtyCategoryTitle = tagView.specialtyCategoryTitle
        if let tagAttribute = specialtyCategoryTitle.associatedTagAttribute {
            switch tagAttribute {
            case .SpecialtyTagMenu:
                let titleArray = specialtyCategoryTitle.specialtyTagTitles.map{$0.toString} //making the array into a string
                dropDownMenu.showTagListView(titleArray, specialtyCategoryTitle: specialtyCategoryTitle)
                dropDownMenu.tagListView!.delegate = self
            default: break
            }
        }
    }
}
