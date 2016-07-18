//
//  FilterTagViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/20/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import TagListView
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
    func createStackViewTagButtonsAndSpecialtyEnviroment(categoryTitleText: String, pushOneButton: Bool) {
        theSpecialtyTagEnviromentHolderView = SpecialtyTagEnviromentHolderView(filterCategory: categoryTitleText, addNoneButton: true, stackViewButtonDelegate: self, pushOneButton: pushOneButton)
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
                self.view.addSubview(theSpecialtyTagEnviromentHolderView)
                theSpecialtyTagEnviromentHolderView.snp_makeConstraints(closure: { (make) in
                    let leadingTrailingOffset : CGFloat = 20
                    make.leading.equalTo(self.view).offset(leadingTrailingOffset)
                    make.trailing.equalTo(self.view).offset(-leadingTrailingOffset)
                    make.top.equalTo(theChosenTagHolderView.snp_bottom)
                    make.bottom.equalTo(self.view)
                })
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
}





