//
//  FilterTagViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit
import Parse
import Foundation

class FilterTagViewController: UIViewController {
    
    @IBOutlet weak var tagChoicesView: TagListView!
    @IBOutlet weak var tagChosenView: TagListView!
    @IBOutlet weak var tagChosenViewWidthConstraint: NSLayoutConstraint!
    var theSpecialtyTagEnviromentHolderView : SpecialtyTagEnviromentHolderView?
    @IBOutlet weak var theChosenTagHolderView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    
    var searchDataArray: [Tag] = []
    var tagChoicesDataArray: [Tag] = []
    //Purpose: this array is for when you add a tag to your profile. It holds all the tags you added to profile, and then when you hit done. It will save them all to Parse.
    var chosenTagArray : [Tag] = []
    
    //search Variables
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addTagListViewAttributes()
        setSearchDataArray()
    }
    
    func loadChoicesViewTags() {
        fatalError("This method must be overridden in subclasses")
    }
    
    //TODO: probably could just sublcass tagListView instead of setting the attributes here
    func addTagListViewAttributes() {
        //did this in code, rather than total storyboard because it has a lot of redundancy
        tagChoicesView.addChoicesTagListViewAttributes()
        tagChosenView.addChosenTagListViewAttributes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FilterTagViewController: TagListViewDelegate {
    func createStackViewTagButtonsAndSpecialtyEnviroment(categoryTitleText: String, pushOneButton: Bool, addNoneButton: Bool) {
        theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(filterCategory: categoryTitleText, addNoneButton: addNoneButton, stackViewButtonDelegate: self, pushOneButton: pushOneButton)
        theSpecialtyTagEnviromentHolderView?.delegate = self
        createSpecialtyTagEnviroment(true)
    }
    
    //Purpose: hides/unhides the specialtyTagEnviroment, like when I want to make stack view buttons, ect.
    func createSpecialtyTagEnviroment(showSpecialtyEnviroment: Bool) {
        tagChoicesView.hidden = showSpecialtyEnviroment
        if let theSpecialtyTagEnviromentHolderView = theSpecialtyTagEnviromentHolderView {
            if !self.view.subviews.contains(theSpecialtyTagEnviromentHolderView) {
                //checking if the holder view has been added to the view, because we need to add it, if it has not.
                self.view.addSubview(theSpecialtyTagEnviromentHolderView)
                theSpecialtyTagEnviromentHolderView.snp_makeConstraints(closure: { (make) in
                    let leadingTrailingOffset : CGFloat = 20
                    make.leading.equalTo(self.view).offset(leadingTrailingOffset)
                    make.trailing.equalTo(self.view).offset(-leadingTrailingOffset)
                    make.top.equalTo(theChosenTagHolderView.snp_bottom)
                    make.bottom.equalTo(self.view)
                })
            }
            theSpecialtyTagEnviromentHolderView.hidden = !showSpecialtyEnviroment
        }
    }
    
    
    //Purpose: I want to be able to have a scroll view that grows/shrinks as tags are added to it.
    func changeTagListViewWidth(tagView: TagView, extend: Bool) {
        let tagWidth = tagView.intrinsicContentSize().width
        let tagPadding : CGFloat = self.tagChosenView.marginX
        //TODO: Not having the X remove button is not accounted for in the framework, so that was why the extension was not working because it was not including the X button.
        if extend {
            //we are adding a tag, and need to make more room
            self.tagChosenViewWidthConstraint.constant += tagWidth + tagPadding
        } else {
            //deleting a tag, so shrink view
            self.tagChosenViewWidthConstraint.constant -= tagWidth + tagPadding
        }
        self.view.layoutIfNeeded()
        //checking to see if tags have outgrown screen because then I want it to slide the newest tag into focus
        if self.view.frame.width <= theChosenTagHolderView.frame.width {
            //I want the scroll view to go to a content offset where I only see the newest added tags. 
            //So, I find out how big the TagHolderViewWidth has grown. Then, I see how big the screen is, and the difference is the area that is off the screen.
            //Therefore, I want to have contentOffset start at the end of the area that has been pushed off screen.
            let screenWidth = self.view.frame.size.width
            let chosenTagHolderViewWidth = theChosenTagHolderView.frame.size.width
            theScrollView.setContentOffset(CGPointMake(chosenTagHolderViewWidth - screenWidth, 0), animated: true)
        }
    }

}

extension FilterTagViewController: StackViewTagButtonsDelegate {
    func createChosenTag(tagTitle: String, specialtyTagTitle: String) {
        let specialtyTagView = tagChosenView.addSpecialtyTag(tagTitle, specialtyTagTitle: specialtyTagTitle)
        changeTagListViewWidth(specialtyTagView, extend: true)
    }
    
    func removeChosenTag(tagTitle: String) {
        //finding the particular tagView, so we know what to pass to the changeTagListWidth
        //removeTag does not return a tagView like addTag does
        if let tagView = tagChosenView.findTagView(tagTitle, categoryName: nil) {
            tagChosenView.removeTag(tagTitle)
            changeTagListViewWidth(tagView, extend: false)
        }
    }
    
    func doesChosenTagViewContain(tagTitle: String) -> Bool {
        return tagChosenView.tagExistsInTagListView(tagTitle)
    }
    
    func editSpecialtyTagView(newTagTitle: String, originalTagTitle: String, specialtyCategoryName: SpecialtyTags) {
        let originalTagView = SpecialtyTagView(tagTitle: originalTagTitle, specialtyTagTitle: specialtyCategoryName.rawValue)
        let newTag = Tag(title: newTagTitle, specialtyCategoryTitle: specialtyCategoryName)
        let tagToDelete = replaceTag(originalTagView, newTag: newTag, tagArray: &tagChoicesDataArray)
        //remove the previous tag from the actual backend
        //TODO: this will be done, without the user knowing if the removal was actually completed. Probably should change that. My other stuff is saving when I hit the done button, so I should also delete when the done button is hit.
        tagToDelete?.deleteInBackground()
        if let originalTagView = tagChoicesView.findTagView(originalTagTitle, categoryName: specialtyCategoryName.rawValue) {
            originalTagView.setTitle(newTagTitle, forState: .Normal)
        }
        chosenTagArray.append(newTag)
        tagChoicesView.layoutSubviews()
    }
}

extension FilterTagViewController: SpecialtyTagEnviromentHolderViewDelegate {
    func unhideChoicesTagListView() {
        createSpecialtyTagEnviroment(false)
    }
    
    //need to override this in addToProfileViewController class
    func createNewPersonalTag(title: String) {}
}

//tag helper extensions 
extension FilterTagViewController {
    //return a new array to set the old array to, and the replaced tag in case something is needed to be done with it
    func replaceTag(originalTagView: TagView, newTag: Tag, inout tagArray: [Tag]) -> Tag? {
        if let originalSpecialtyTagView = originalTagView as? SpecialtyTagView {
            //checks if specialty tag is equal in both title and specialtyTitle. That is how we know we have exact match
            if let tagIndex = tagArray.indexOf({($0.title == originalTagView.titleLabel?.text && $0.specialtyCategoryTitle == originalSpecialtyTagView.specialtyTagTitle)}) {
                //replace old tag in the array with our new one. Deleting from chosenTagArray because I don't want it saving to original backend.
                let originalTag = tagArray[tagIndex]
                tagArray[tagIndex] = newTag
                return originalTag
            }
        } else {
            //dealing with Generic tag
            if let tagIndex = tagArray.indexOf({$0.title == originalTagView.titleLabel?.text}) {
                //replace old tag in the array with our new one. Deleting from chosenTagArray because I don't want it saving to original backend.
                let originalTag = tagArray[tagIndex]
                tagArray[tagIndex] = newTag
                return originalTag
            }
        }
        //if the tag does not exist in the array
        return nil
    }
    
    func findTag(tagView: TagView, tagArray: [Tag]) -> Tag? {
        if let tagIndex = tagArray.indexOf({$0.title == tagView.titleLabel?.text}) {
            //replace old tag in the array with our new one. Deleting from chosenTagArray because I don't want it saving to original backend.
            return tagArray[tagIndex]
        }
        //tag does not exist in array
        return nil
    }
    
}

//search extension
extension FilterTagViewController: UISearchBarDelegate {
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
        fatalError("This method must be overridden in subclasses")
    }
    
    //TODO; right now, my search is pulling down the entire tag table and then doing search,
    //very ineffecient, and in future, I will have to do server side cloud code.
    //Also, it is pulling down duplicate tag titles, Example: Two Users might have a blonde tag, but for searching purposes, I only need to have one blonde tag. Right now pulling down all tags, which again is ineffecient
    func setSearchDataArray() {
        addSpecialtyTagsToSearchDataArray()
        var alreadyContainsTagArray: [String] = []
        let query = PFQuery(className: "Tag")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                for tag in tags {
                    if !alreadyContainsTagArray.contains(tag.title) {
                        //our string array does not already contain the tag title, so we can add it to our searchable array
                        alreadyContainsTagArray.append(tag.title)
                        self.searchDataArray.append(tag)
                    }
                }
            }
        }
    }
    
    func addSpecialtyTagsToSearchDataArray() {
        for filterName in FilterNames.allValues {
            searchDataArray.append(Tag(title: filterName.rawValue, specialtyCategoryTitle: findSpecialtyCategoryName(filterName.rawValue)))
        }
    }
    
    func resetTagChoicesViewList() {
        tagChoicesView.removeAllTags()
        loadChoicesViewTags()
        createSpecialtyTagEnviroment(false)
        theSpecialtyTagEnviromentHolderView?.removeFromSuperview()
    }
}





