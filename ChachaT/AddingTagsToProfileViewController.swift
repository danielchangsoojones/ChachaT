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
import Timepiece

class AddingTagsToProfileViewController: SuperTagViewController {
    @IBOutlet weak var theActivityIndicator: UIActivityIndicatorView!
    var creationMenuView: CreationMenuView!
    
    var dataStore : AddingTagsDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagChoicesView.delegate = self
        createCreationTagView()
        setDataFromDataStore()
        setTapGestureToCloseKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //the alertview, the first time I clicked a tag, was not loading quickly. But, subsequent alerts were loading
        //quickly, so I added this to already load a SCLAlertView, so then when a tag is hit, it loads quickly
        //this actually seems to make it work. But, maybe it is just an illusion to me...
        let _ = SCLAlertView()
    }
    
    func setDataFromDataStore() {
        dataStore = AddingTagsDataStore(delegate: self) //sets the data for the tag arrays
    }
    
    //Purpose: the first tag view needs to be a tag view that says "Add tags..." in a different color, and when the user clicks, they can start typing right there.
    //This should create a drop down menu of all available tags
    func createCreationTagView() {
        let tagView = CreationTagView(textFieldDelegate: self, delegate: self, textFont: tagChoicesView.textFont, paddingX: tagChoicesView.paddingX, paddingY: tagChoicesView.paddingY, borderWidth: tagChoicesView.borderWidth, cornerRadius: tagChoicesView.cornerRadius, tagBackgroundColor: tagChoicesView.tagBackgroundColor)
        //TODO: move this the CreationTagView class
        tagView.borderColor = UIColor.black
        _ = tagChoicesView.addTagView(tagView)
    }
    
    //Purpose: the user should be able to tap, when keyboard is showing, anywhere to dismiss the keyboard
    //IF YOU EVER HAVE WEIRD GESTURES NOT BEING RECOGNIZED, THIS GESTURE RECOGNIZER IS PROBABLY THE PROBLEM
    func setTapGestureToCloseKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(AddingTagsToProfileViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddingTagsToProfileViewController.dismissTheKeyboard))
        view.addGestureRecognizer(tap)
        //gesture recognizers usually fucks with tableView SelectAtIndexRow, but setting this property to false allows the tap to pass through to the tableView
        tap.cancelsTouchesInView = false
    }
    
    override func passSearchResults(searchTags: [Tag]) {
        if let addingTagView = findCreationTagView() {
            let currentSearchText: String = addingTagView.searchTextField.text ?? ""
            if searchTags.isEmpty {
                //TODO: If we can't find any more tags here, then stop querying any farther if the user keeps typing
                creationMenuView.toggleMenuType(.newTag, newTagTitle: currentSearchText, tagTitles: nil)
            } else {
                //search results exist
                var tagTitles: [String] = searchTags.map({ (tag: Tag) -> String in
                    return tag.title
                })
                if !tagTitles.contains(currentSearchText) {
                    tagTitles.append(currentSearchText)
                }
                creationMenuView.toggleMenuType(.existingTags, newTagTitle: nil, tagTitles: tagTitles)
            }
        }
    }
    
    override func addDropDownTag(tag: Tag) {
        if let dropDownTag = tag as? DropDownTag {
            switch dropDownTag.dropDownAttribute {
            case .tagChoices:
                let _ = tagChoicesView.addDropDownTag(dropDownTag.title, specialtyCategoryTitle: dropDownTag.specialtyCategory) as! DropDownTagView
            case .singleSlider, .rangeSlider:
                createCustomTags(dropDownTag: dropDownTag)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//tag methods extension
extension AddingTagsToProfileViewController {
    //TagListView tags: (tagChoicesView = 1, tagChosenView = 2, dropDownTagView = 3)
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 1 {
            //tagChoicesView pressed
            let alertView = SCLAlertView()
            _ = alertView.addButton("Delete") {
                self.dataStore.deleteTag(title)
                sender.removeTagView(tagView)
            }
            _ = alertView.showError("Delete", subTitle: "Do you want to delete this tag?", closeButtonTitle: "Cancel")
        } else if sender.tag == 3 {
            //ChachaDropDownTagView pressed
            dropDownMenu.hide()
            if let dropDownTagView = tappedDropDownTagView {
                tagChoicesView.setTagViewTitle(dropDownTagView, title: title)
                dataStore.saveSpecialtyTag(title: title, specialtyCategory: dropDownTagView.specialtyCategoryTitle)
            }
        }
    }
    
    func specialtyTagPressed(_ title: String, tagView: SpecialtyTagView, sender: TagListView) {
        if sender.tag == 1 {
            //dealing with the tagChoicesView
            switch tagView.tagAttribute {
            case .dropDownMenu:
                tappedDropDownTagView = tagView as? DropDownTagView
                if let dropDownTag = findDropDownTag(tappedDropDownTagView!.specialtyCategoryTitle, array: tagChoicesDataArray) {
                    dropDownActions(dropDownTag)
                }
            default: break
            }
        }
    }
}

//Extension for adding some custom tags like "Age". "Height"
extension AddingTagsToProfileViewController {
    fileprivate func createCustomTags(dropDownTag: DropDownTag) {
        switch dropDownTag.databaseColumnName {
        case CustomDropDownParseColumnNames.height:
            performHeightTagAction(dropDownTag: dropDownTag)
        case CustomDropDownParseColumnNames.age:
            performAgeTagAction(dropDownTag: dropDownTag)
        default:
            break
        }
    }
    
    fileprivate func performHeightTagAction(dropDownTag: DropDownTag) {
        addCustomTagViews(dropDownTag: dropDownTag, innerAnnotationText: User.current()!.heightConvertedToString) { (specialtyTagView: SpecialtyTagView) in
            let storyboard = UIStoryboard(name: "AddingTags", bundle: nil)
            let heightPickerVC = storyboard.instantiateViewController(withIdentifier: "HeightPickerViewController") as! HeightPickerViewController
            heightPickerVC.passHeight = { (height: String, totalInches: Int) in
                specialtyTagView.annotationView?.updateText(text: height)
                self.dataStore.saveCustomActionTag(databaseColumnName: dropDownTag.databaseColumnName, itemToSave: totalInches)
            }
            self.navigationController?.pushViewController(heightPickerVC, animated: true)
        }
    }
    
    fileprivate func performAgeTagAction(dropDownTag: DropDownTag) {
        let currentAge: Int = User.current()!.age ?? 0
        addCustomTagViews(dropDownTag: dropDownTag, innerAnnotationText: currentAge.toString) { (specialtyTagView: SpecialtyTagView) in
            DatePickerDialog().show("Your Birthday!", defaultDate: User.current()!.birthDate ?? Date(),  datePickerMode: .date) {
                (birthday) -> Void in
                //TODO: the date dialog should pop up to the user's previous inputted bday if they have one
                let age = User.current()!.calculateAge(birthday: birthday)
                specialtyTagView.annotationView?.updateText(text: "\(age)")
                self.dataStore.saveCustomActionTag(databaseColumnName: dropDownTag.databaseColumnName, itemToSave: birthday)
            }
        }
    }
    
    fileprivate func addCustomTagViews(dropDownTag: DropDownTag, innerAnnotationText: String, onTap: @escaping (SpecialtyTagView) -> ()) {
        let tagView = tagChoicesView.addSpecialtyTag(dropDownTag.title, tagAttribute: .innerText, innerAnnotationText: innerAnnotationText)
        tagView.onTap = { (tagView: TagView) in
            if let specialtyTagView = tagView as? SpecialtyTagView {
                onTap(specialtyTagView)
            }
        }
    }
}

extension AddingTagsToProfileViewController: CreationTagViewDelegate {
    func textFieldDidChange(_ searchText: String) {
        if creationMenuView == nil {
            //when we use the mac simulator, sometimes, the keyboard is not toggled. And, the creationMenuView uses the height of the keyboard to calculate its height. Hence, if the keyboard doesn't show, then the creationMenuView would be nil. By just having a nil check here, we stop the mac simulator from crashing, even though a real device would not need this code/wouldn't crash.
            createTagMenuView(0)
        }
        creationMenuView.removeAllTags()
        creationMenuView.isHidden = false
        //we already check if the text is empty over in the CreationTagView class
        dataStore.searchForTags(searchText: searchText)
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //TODO: hide all tagViews that aren't the CreationTagView, meaning clear the screen.
        creationMenuView?.isHidden = false
    }
    
    //Calls this function when the tap is recognized anywhere on the screen that is not a tappable object.
    func dismissTheKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resetTextField()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textFieldDidEndEditing(textField)
        return false //for some reason, I have to return false in order for the textField to resignTheFirst responder propoerly
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //the return button hit
        if let tagView = creationMenuView.choicesTagListView.tagViews.first, let currentTitle = tagView.currentTitle {
            creationMenuView.tagPressed(currentTitle, tagView: tagView, sender: creationMenuView.choicesTagListView)
        }
        return true
    }
    
    func resetTextField() {
        if let addingTagView = findCreationTagView() {
            addingTagView.searchTextField.text = ""
            dismissTheKeyboard() //calls the textFieldDidEndEditing method, which hides the CreationMenuView
            creationMenuView?.isHidden = true
        }
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        //creating the creationMenuView here because we only want it to be visible above the keyboard, so they can scroll through all available tags.
        //But, we can only get the keyboard height through this notification.
        createTagMenuView(keyboardHeight)
    }
    
    func createTagMenuView(_ keyboardHeight: CGFloat) {
        if creationMenuView == nil {
            creationMenuView = CreationMenuView.instanceFromNib(self)
        }
        //TODO: should this add subview be up in the nil check area? we don't want to add this multiple times to the view
        self.view.addSubview(creationMenuView)
        //TODO: I don't know why, but by setting the hidden value on the tagMenuView when I want it to disappear, it makes the height constraint = 0, so I need to remake the constraints to make the CreationMenu show up a second time. This fixes it. But, might be a better way, where I don't have to set constraints every time the keyboard appears.
        creationMenuView.snp.remakeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view).inset(keyboardHeight)
            if let addingTagView = findCreationTagView() {
                //We can't just snp the top to addingTagView.snp.bottom, becuase when we rearrange the tagViews, the constraints get messed up. So, we snp it to the bottom of the addingTagView but make sure that the offset is a constant. 
                make.top.equalTo(tagChoicesView.snp.top).offset(addingTagView.frame.height)
            }
        }
    }
}

extension AddingTagsToProfileViewController: AddingTagMenuDelegate {
    func addNewTagToTagChoiceView(title: String) {
        tagChoicesView.insertTagViewAtIndex(1, title: title)
        resetTextField()
        dataStore.saveNewTag(title: title)
    }
    
}
