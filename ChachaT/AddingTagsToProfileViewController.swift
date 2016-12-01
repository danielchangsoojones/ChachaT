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
    var theTagCreationVC: TagCreationViewController!
    @IBOutlet weak var theContentView: UIView!
    
    var dataStore : AddingTagsDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTagCreationHolderView()
        setDataFromDataStore()
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
    
    override func passSearchResults(searchTags: [Tag]) {
        theTagCreationVC.passSearchedTags(searchTags: searchTags)
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
    
    override func getMostCurrentSearchText() -> String {
        return theTagCreationVC.getCurrentSearchText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//Tag Creation Holder View extension
extension AddingTagsToProfileViewController {
    fileprivate func createTagCreationHolderView() {
        let holderView = UIView()
        theContentView.addSubview(holderView)
        holderView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        addTagCreationChildVC(holderView: holderView)
    }
    
    func addTagCreationChildVC(holderView: UIView) {
        theTagCreationVC = TagCreationViewController(delegate: self)
        theTagCreationVC.creationTagListView.delegate = self
        addAsChildViewController(theTagCreationVC, toView: holderView)
        theTagCreationVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tagChoicesView = theTagCreationVC.creationTagListView
    }
}

extension AddingTagsToProfileViewController: TagCreationViewControllerDelegate {
    func keyboardChanged(keyboardHeight: CGFloat) {}
    
    func searchForTags(searchText: String) {
        dataStore.searchForTags(searchText: searchText)
    }
    
    func saveNewTag(title: String) {
        dataStore.saveNewTag(title: title)
        theTagCreationVC.insertTagViewAtFront(tagView: TagView(title: title))
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
            addHeightTag(dropDownTag: dropDownTag)
        case CustomDropDownParseColumnNames.age:
            addAgeTag(dropDownTag: dropDownTag)
        default:
            break
        }
    }
    
    fileprivate func addHeightTag(dropDownTag: DropDownTag) {
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
    
    fileprivate func addAgeTag(dropDownTag: DropDownTag) {
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
