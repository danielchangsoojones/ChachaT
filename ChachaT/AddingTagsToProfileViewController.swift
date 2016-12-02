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
import EZSwiftExtensions
import DatePickerDialog

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
    
    override func loadTag(tag: Tag) {
        if tag.isPending {
            //add a pendingTagView
            let pendingTagView = PendingTagView(title: tag.title, topLabelTitle: "Approve?")
            tagChoicesView.insertTagViewAtIndex(1, tagView: pendingTagView)
        } else {
            super.loadTag(tag: tag)
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
    
    override func getMostCurrentSearchText() -> String {
        return theTagCreationVC.getCurrentSearchText()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true //need to do this to allow UIMenuItems to work
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
            make.bottom.trailing.leading.equalToSuperview()
            //add the inset, so we could see the little words that say pending and stuff
            make.top.equalToSuperview().inset(10)
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
            if !isPendingTagView(tagView: tagView) {
                let alertView = SCLAlertView()
                _ = alertView.addButton("Delete") {
                    self.dataStore.deleteTag(title)
                    sender.removeTagView(tagView)
                }
                _ = alertView.showError("Delete", subTitle: "Do you want to delete this tag?", closeButtonTitle: "Cancel")
            }
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

//Pending Tags extension
extension AddingTagsToProfileViewController {
    fileprivate func isPendingTagView(tagView: TagView) -> Bool {
        if let pendingTagView = tagView as? PendingTagView {
            showMenuController(pendingTagView: pendingTagView)
        }
        return tagView is PendingTagView
    }
    
    fileprivate func showMenuController(pendingTagView: PendingTagView) {
        if !pendingTagView.isApproved {
            let menu = UIMenuController.shared
            
            let approveItem = MyMenuItem(title: "Approve", action: #selector(approveTag(sender:)), correspondingObject: pendingTagView)
            let rejectItem = MyMenuItem(title: "Reject", action: #selector(rejectTag(sender:)), correspondingObject: pendingTagView)
            let createdByItem = MyMenuItem(title: "Created By", action: #selector(segueToCreatedBy(sender:)), correspondingObject: findTag(title: pendingTagView.currentTitle ?? ""))
            
            menu.menuItems = [approveItem, rejectItem, createdByItem]
            
            let frame = tagChoicesView.convert(pendingTagView.frame, from: pendingTagView.superview)
            menu.setTargetRect(frame, in: tagChoicesView)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    func approveTag(sender: UIMenuController) {
        //TODO: hard coding the menuItems num to access the correspondingObject, this cold break if things change
        if let myMenuItem = sender.menuItems?[0] as? MyMenuItem, let pendingTagView = myMenuItem.correspondingObject as? PendingTagView, let currentTitle = pendingTagView.currentTitle {
            pendingTagView.approve()
            dataStore.approveTag(title: currentTitle)
            if let tag = findTag(title: currentTitle) {
                tag.isPending = false
            }
        }
    }
    
    func rejectTag(sender: UIMenuController) {
        if let myMenuItem = sender.menuItems?[1] as? MyMenuItem, let pendingTagView = myMenuItem.correspondingObject as? PendingTagView, let currentTitle = pendingTagView.currentTitle {
            tagChoicesView.removeTag(currentTitle)
            dataStore.rejectTag(title: currentTitle)
            
            tagChoicesDataArray = tagChoicesDataArray.filter({ (tag: Tag) -> Bool in
                return tag.title != currentTitle
            })
        }
    }
    
    func segueToCreatedBy(sender: UIMenuController) {
        if let myMenuItem = sender.menuItems?[2] as? MyMenuItem, let tag = myMenuItem.correspondingObject as? Tag, let createdBy = tag.createdBy {
            segueToCardDetailVC(userOfCard: createdBy)
        }
    }
    
    private func segueToCardDetailVC(userOfCard: User) {
        //TODO: make swipeable when they get to other users page.
        let cardDetailVC = CardDetailViewController.createCardDetailVC(userOfCard: userOfCard)
        pushVC(cardDetailVC)
    }
    
    fileprivate func findTag(title: String) -> Tag? {
        let tag = tagChoicesDataArray.first { (tag: Tag) -> Bool in
            return tag.title == title
        }
        
        return tag
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
            DatePickerDialog().show(title: "Your Birthday!", defaultDate: User.current()!.birthDate ?? Date(),  datePickerMode: .date) {
                (birthday) -> Void in
                if let birthday = birthday {
                    let age = User.current()!.calculateAge(birthday: birthday)
                    specialtyTagView.annotationView?.updateText(text: "\(age)")
                    self.dataStore.saveCustomActionTag(databaseColumnName: dropDownTag.databaseColumnName, itemToSave: birthday)
                }
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
