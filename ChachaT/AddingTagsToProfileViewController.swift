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

class AddingTagsToProfileViewController: SuperTagViewController {
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
extension AddingTagsToProfileViewController : TagListViewDelegate {
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

extension AddingTagsToProfileViewController: CreationTagViewDelegate {
    func textFieldDidChange(searchText: String) {
        let filtered : [String] = filterArray(searchText, searchDataArray: searchDataArray)
        //IF THE CREATIONMENUVIEW IS CRASHING ON MAC SIMULATOR, TOGGLE THE KEYBOARD ON THE SIMULATOR, IT WILL CRASH WHEN THE SIMULATOR ISN'T SHOWING BECAUSE FUNCTION KEYBOARDWILLSHOW IS NEVER CALLED. BUT, SHOULD WORK WHEN KEYBOARD IS SHOWN.
        creationMenuView.removeAllTags()
        //we already check if the text is empty over in the CreationTagView class
        if filtered.isEmpty {
            //there is text, but it has no matches in the database
            creationMenuView.toggleMenuType(.Table, newTagTitle: searchText, tagTitles: nil)
        } else {
            //there is text, and we have a match, so the tagChoicesView changes accordingly
            creationMenuView.toggleMenuType(.Tags, newTagTitle: nil, tagTitles: filtered)
        }
    }
    
    //TODO: could probably be a better way to get CreationTagView because this just finds the first instance, and there only happens to be one instance. But, if we ever wanted two for some reason, then this would break.
    //Purpose: find the tagView that is an CreationTagView, because we want to do special things to that one.
    func findCreationTagView() -> CreationTagView? {
        for tagView in tagChoicesView.tagViews where tagView is CreationTagView {
            return tagView as? CreationTagView
        }
        return nil //shouldn't reach this point
    }
}

//textField Delegate Extension for the CreationTagView textField
extension AddingTagsToProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        //TODO: hide all tagViews that aren't the CreationTagView, meaning clear the screen.
        creationMenuView?.hidden = false
    }
    
    //Calls this function when the tap is recognized anywhere on the screen that is not a tappable object.
    func dismissTheKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        creationMenuView?.hidden = true
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardHeight = keyboardRectangle.height
        //creating the creationMenuView here because we only want it to be visible above the keyboard, so they can scroll through all available tags.
        //But, we can only get the keyboard height through this notification.
        //IF THE CREATIONMENUVIEW IS CRASHING ON MAC SIMULATOR, TOGGLE THE KEYBOARD ON THE SIMULATOR, IT WILL CRASH WHEN THE SIMULATOR ISN'T SHOWING BECAUSE FUNCTION KEYBOARDWILLSHOW IS NEVER CALLED. BUT, SHOULD WORK WHEN KEYBOARD IS SHOWN.
        createTagMenuView(keyboardHeight)
    }
    
    func createTagMenuView(keyboardHeight: CGFloat) {
        if creationMenuView == nil {
            creationMenuView = CreationMenuView.instanceFromNib(self)
        }
        self.view.addSubview(creationMenuView)
        //TODO: I don't know why, but by setting the hidden value on the tagMenuView when I want it to disappear, it makes the height constraint = 0, so I need to remake the constraints to make the CreationMenu show up a second time. This fixes it. But, might be a better way, where I don't have to set constraints every time the keyboard appears.
        creationMenuView.snp_remakeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).inset(keyboardHeight)
            if let addingTagView = findCreationTagView() {
                make.top.equalTo(addingTagView.snp_bottom)
            }
        }
    }
}

extension AddingTagsToProfileViewController: AddingTagMenuDelegate {
    func addNewTagToTagChoiceView(title: String, tagView: TagView?) {
        //also passing the TagView because I get the feeling that I might need it in the future.
        tagChoicesView.insertTagViewAtIndex(1, title: title, tagView: tagView)
        if let addingTagView = findCreationTagView() {
            addingTagView.searchTextField.text = ""
            resignFirstResponder() //calls the textFieldDidEndEditing method, which hides the CreationMenuView
        }
        dataStore.saveNewTag(title)
    }
    
}
