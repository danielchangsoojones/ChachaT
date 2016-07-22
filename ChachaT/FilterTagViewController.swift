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

class FilterTagViewController: OverlayAnonymousFlowViewController {
    
    @IBOutlet weak var tagChoicesView: TagListView!
    @IBOutlet weak var tagChosenView: TagListView!
    @IBOutlet weak var tagChosenViewWidthConstraint: NSLayoutConstraint!
    var theSpecialtyTagEnviromentHolderView : SpecialtyTagEnviromentHolderView?
    @IBOutlet weak var theChosenTagHolderView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    
    var allParseTags: [Tag] = []
    var currentUserTags: [Tag] = []
    //Purpose: this array is for when you add a tag to your profile. It holds all the tags you added to profile, and then when you hit done. It will save them all to Parse.
    var chosenTagArray : [Tag] = []
    
    //search Variables
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addTagListViewAttributes()
        setSearchDataArray()
    }
    
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
        createSpecialtyTagEnviroment(false)
    }
    
    func tagExistsInChosenTagListView(tagListView: TagListView, title: String) -> Bool {
        for tagView in tagListView.tagViews {
            if tagView.titleLabel?.text == title {
                return true
            }
        }
        return false
    }
    
    func createSpecialtyTagEnviroment(specialtyEnviromentHidden: Bool) {
        tagChoicesView.hidden = !specialtyEnviromentHidden
        if let theSpecialtyTagEnviromentHolderView = theSpecialtyTagEnviromentHolderView {
            if !self.view.subviews.contains(theSpecialtyTagEnviromentHolderView) && !specialtyEnviromentHidden {
                //checking if the holder view has been added to the view, because we need to add it, if it has not. 
                //we also want to make sure that the specialtyTagEnviromentView is supposed to be shown
                theSpecialtyTagEnviromentHolderView.hidden = specialtyEnviromentHidden
                self.view.addSubview(theSpecialtyTagEnviromentHolderView)
                theSpecialtyTagEnviromentHolderView.snp_makeConstraints(closure: { (make) in
                    let leadingTrailingOffset : CGFloat = 20
                    make.leading.equalTo(self.view).offset(leadingTrailingOffset)
                    make.trailing.equalTo(self.view).offset(-leadingTrailingOffset)
                    make.top.equalTo(theChosenTagHolderView.snp_bottom)
                    make.bottom.equalTo(self.view)
                })
            } else if specialtyEnviromentHidden {
                theSpecialtyTagEnviromentHolderView.hidden = specialtyEnviromentHidden
            }
        }
    }
    
    
    //Purpose: I want to be able to have a scroll view that grows/shrinks as tags are added to it.
    func changeTagListViewWidth(tagView: TagView, extend: Bool) {
        let originalTagChosenViewMaxX = tagChosenView.frame.maxX
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
        if self.view.frame.width <= theChosenTagHolderView.frame.width {
            //TODO: did -100 because it looks better, and I could not figure out exact math. I want it to look like 8tracks, where after it grows bigger than the screen
            //it stays in the same spot
            theScrollView.setContentOffset(CGPointMake(originalTagChosenViewMaxX - 100, 0), animated: true)
        }
    }

}

extension FilterTagViewController: StackViewTagButtonsDelegate {
    func createChosenTag(tagTitle: String) {
        let tagView = tagChosenView.addTag(tagTitle)
        changeTagListViewWidth(tagView, extend: true)
    }
    
    func removeChosenTag(tagTitle: String) {
        //finding the particular tagView, so we know what to pass to the changeTagListWidth
        //removeTag does not return a tagView like addTag does
        for tagView in tagChosenView.tagViews where tagView.currentTitle == tagTitle {
            tagChosenView.removeTag(tagTitle)
            changeTagListViewWidth(tagView, extend: false)
        }
    }

    func removeChoicesTag(tagTitle: String) {
        tagChoicesView.removeTag(tagTitle)
    }
    
    func doesChosenTagViewContain(tagTitle: String) -> Bool {
        return tagExistsInChosenTagListView(tagChosenView, title: tagTitle)
    }
    
    func editSpecialtyTagView(newTagTitle: String, originalTagTitle: String, filterNameCategory: SpecialtyTags) {
        for tag in self.currentUserTags where tag.title == originalTagTitle {
            //delete element in array
            if let tagIndex = self.currentUserTags.indexOf(tag) {
                 self.currentUserTags.removeAtIndex(tagIndex)
            }
            //remove the previous tag from the actual backend
            //TODO: this will be done, without the user knowing if the removal was actually completed. Probably should change that. My other stuff is saving when I hit the done button, so I should also delete when the done button is hit.
            tag.deleteInBackground()
        }
        
        for tagView in tagChoicesView.tagViews where tagView.titleLabel?.text == originalTagTitle {
            if let specialtyTagView = tagView as? SpecialtyTagView {
                //I am trying to pinpoint the specialtyTagView that has both the correct title and correct filter category title
                //because if I just used the tagTitle, then if multiple special tags have ?, then they all change instead of just one.
                if specialtyTagView.specialtyTagTitle == filterNameCategory.rawValue {
                    specialtyTagView.setTitle(newTagTitle, forState: .Normal)
                    let newTag = Tag(title: newTagTitle, attribute: TagAttributes.SpecialtyButtons, specialtyCategoryTitle: SpecialtyTags(rawValue: specialtyTagView.specialtyTagTitle))
                    self.currentUserTags.append(newTag)
                    chosenTagArray.append(newTag)
                    tagChoicesView.layoutSubviews()
                }
            }
        }
    }
}

extension FilterTagViewController: SpecialtyTagEnviromentHolderViewDelegate {
    func unhideChoicesTagListView() {
        createSpecialtyTagEnviroment(true)
    }
    
    //need to override in subclass method
    func addToProfileTagArray(title: String) {}
}

//search extension
extension FilterTagViewController {
    //TODO; right now, my search is pulling down the entire tag table and then doing search,
    //very ineffecient, and in future, I will have to do server side cloud code.
    //Also, it is pulling down duplicate tag titles, Example: Two Users might have a blonde tag, but for searching purposes, I only need to have one blonde tag. Right now pulling down all tags, which again is ineffecient
    func setSearchDataArray() {
        addSpecialtyTagsToSearchDataArray()
        var alreadyContainsTagArray: [String] = []
        let query = PFQuery(className: "Tag")
        query.selectKeys(["title"])
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let tags = objects as? [Tag] {
                for tag in tags {
                    if !alreadyContainsTagArray.contains(tag.title) {
                        //our string array does not already contain the tag title, so we can add it to our searchable array
                        alreadyContainsTagArray.append(tag.title)
                        self.allParseTags.append(tag)
                    }
                }
            }
        }
    }
    
    func addSpecialtyTagsToSearchDataArray() {
        for filterName in FilterNames.allValues {
            allParseTags.append(Tag(title: filterName.rawValue, attribute: TagAttributes.SpecialtyButtons, specialtyCategoryTitle: findFilterNameCategory(filterName.rawValue)))
        }
    }
}





