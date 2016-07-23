//
//  FilterQueryViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EFTools

class FilterQueryViewController: FilterTagViewController {
    
    var mainPageDelegate: FilterViewControllerDelegate?
    
    @IBAction func theDoneButtonPressed(sender: UIBarButtonItem) {
        var chosenTagArrayTitles : [String] = []
        for tagView in tagChosenView.tagViews {
            if let titleLabel = tagView.titleLabel {
                if let title = titleLabel.text {
                    //need to get title array because I want to do contained in query, which requires strings
                    chosenTagArrayTitles.append(title)
                }
            }
        }
        let query = Tag.query()
        //finding all tags that have a title that the user chose for the search
        //TODO: I'll need to do something if 0 people come up
        if !chosenTagArrayTitles.isEmpty {
            query?.whereKey("title", containedIn: chosenTagArrayTitles)
        }
        query?.includeKey("createdBy")
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error == nil {
                var userArray : [User] = []
                for tag in objects as! [Tag] {
                    userArray.append(tag.createdBy!)
                }
                self.mainPageDelegate?.passFilteredUserArray(userArray)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                print(error)
            }
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTagsInTagChoicesDataArray()
        tagChoicesView.delegate = self
        tagChosenView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


//extension for working with tags
extension FilterQueryViewController {
    //TODO: could potentially make a subclass of TagView to do this, but this works for now. Since, I am only changing one thing.
    //Purpose: Make the specialty tags look different than just generic tags, but don't want the double sided tags because we only want clickable ones
    func setSpecialtyTagAttributes(tagView: TagView) {
        let specialtyTagColor = UIColor.blueColor()
        tagView.tagBackgroundColor = specialtyTagColor
        tagView.highlightedBackgroundColor = specialtyTagColor
    }
    
    override func loadChoicesViewTags() {
        for tag in tagChoicesDataArray {
            tagChoicesView.addTag(tag.title)
        }
    }
    
    func setTagsInTagChoicesDataArray() {
        //adding in generic tags
        //TODO: this is requerying the database every time to do this, it should just get the array once, and then use that.
        //Although this whole function will change because I only want us to get a certain number of tags, and I don't want it to just be random.
        let query = Tag.query()
        query?.whereKey("attribute", equalTo: TagAttributes.Generic.rawValue)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) in
            if error == nil {
                for tag in objects as! [Tag] {
                    self.tagChoicesDataArray.append(tag)
                }
                self.setSpecialtyTagsIntoDefaultView()
                self.loadChoicesViewTags()
            } else {
                print(error)
            }
        })
    }
    
    
    //Purpose: I want when you first come onto search page, that you see a group of tags already there that you can instantly press
    //I want mostly special tags like "Age Range", "Location", ect. to be there.
    func setSpecialtyTagsIntoDefaultView() {
        for specialtyTag in SpecialtyTags.allValues {
            let tagView = tagChoicesView.addTag(specialtyTag.rawValue)
            setSpecialtyTagAttributes(tagView)
            tagChoicesDataArray.append(Tag(title: specialtyTag.rawValue, specialtyCategoryTitle: specialtyTag))
        }
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        if let tag = findTag(tagView, tagArray: tagChoicesDataArray) {
            switch tag.attribute {
            case TagAttributes.Generic.rawValue:
                let tagView = tagChosenView.addTag(tag.title)
                tagChoicesView.removeTag(tag.title)
                changeTagListViewWidth(tagView, extend: true)
            case TagAttributes.SpecialtyButtons.rawValue:
                createStackViewTagButtonsAndSpecialtyEnviroment(title, pushOneButton: false, addNoneButton: false)
            case TagAttributes.SpecialtySingleSlider.rawValue:
                //TODO: make the specialty slider come up
                break
            case TagAttributes.SpecialtyRangeSlider.rawValue:
                //TODO: make the specialty slider come up
                break
            default: break
            }
        }
    }
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 2 {
            //we are dealing with ChosenTagListView because I set the tag in storyboard to be 2
            sender.removeTagView(tagView)
            changeTagListViewWidth(tagView, extend: false)
        }
    }
}

//search extension
extension FilterQueryViewController {
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
            //TODO: it should say no matches to your search, maybe be the first to join?
//            searchActive = true
//            if !(theSpecialtyTagEnviromentHolderView?.theSpecialtyView is TagListView) {
//                theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(specialtyTagEnviroment: .CreateNewTag)
//                theSpecialtyTagEnviromentHolderView?.delegate = self
//            }
//            createSpecialtyTagEnviroment(false)
//            theSpecialtyTagEnviromentHolderView?.updateTagListView(searchText)
//            theSpecialtyTagEnviromentHolderView?.setButtonText("Create New Tag?")
        } else {
            //there is text, and we have a match, so the tagChoicesView changes accordingly
            searchActive = true
            for tag in filtered {
                tagChoicesView.addTag(tag.title)
            }
            createSpecialtyTagEnviroment(false)
        }
    }
}

