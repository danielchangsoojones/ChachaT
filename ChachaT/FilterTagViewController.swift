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
    
    @IBOutlet weak var tagChoicesView: ChachaChoicesTagListView!
    var tagChosenView : ChachaChosenTagListView!
    @IBOutlet weak var backgroundColorView: UIView!
    var theSpecialtyTagEnviromentHolderView : SpecialtyTagEnviromentHolderView?
    var scrollViewSearchView : ScrollViewSearchView!
    var dropDownMenu: ChachaTagDropDown!
    
    //constraint outlets
    @IBOutlet weak var tagChoicesViewTopConstraint: NSLayoutConstraint!
    
    var searchDataArray: [String] = []
    var tagChoicesDataArray: [String] = []
    //TODO: probably get rid of chosenTagArray
    //Purpose: this array is for when you add a tag to your profile. It holds all the tags you added to profile, and then when you hit done. It will save them all to Parse.
    var chosenTagArray : [String] = []
    var theSpecialtyChosenTagDictionary : [SpecialtyCategoryTitles : TagView?] = [ : ]
    var theGenericChosenTagArray : [String] = []
    
    //search Variables
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewSearchView = addSearchScrollView()
        setDropDownMenu()
        backgroundColorView.backgroundColor = BackgroundPageColor
    }
    
    func loadChoicesViewTags() {
        fatalError("This method must be overridden in subclasses")
    }
    
    func addSearchScrollView() -> ScrollViewSearchView {
        //getting the xib file for the scroll view
        let scrollViewSearchView = ScrollViewSearchView.instanceFromNib()
        scrollViewSearchView.searchBox.delegate = self
        self.navigationController?.navigationBar.addSubview(scrollViewSearchView)
        scrollViewSearchView.snp_makeConstraints { (make) in
            make.edges.equalTo((self.navigationController?.navigationBar)!)
        }
        setChosenTagView(scrollViewSearchView)
        return scrollViewSearchView
    }
    
    func setChosenTagView(scrollViewSearchView: ScrollViewSearchView) {
        tagChosenView = scrollViewSearchView.theTagChosenListView
        tagChosenView.delegate = self
    }
    
    func setDropDownMenu() {
        let navigationBarHeight = navigationController?.navigationBar.frame.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        dropDownMenu = ChachaTagDropDown(containerView: (navigationController?.view)!, popDownOriginY: navigationBarHeight! + statusBarHeight, delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FilterTagViewController {
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
                    make.top.equalTo(self.view.snp_bottom)
                    make.bottom.equalTo(self.view)
                })
            }
            theSpecialtyTagEnviromentHolderView.hidden = !showSpecialtyEnviroment
        }
    }

}

extension FilterTagViewController: StackViewTagButtonsDelegate {
    func createChosenTag(tagTitle: String, specialtyTagTitle: String) {
        if let scrollViewSearchView = scrollViewSearchView {
            let tagView = scrollViewSearchView.theTagChosenListView.addTag(tagTitle)
            scrollViewSearchView.rearrangeSearchArea(tagView, extend: true)
        }
    }
    
//    func editSpecialtyTagView(newTagTitle: String, originalTagTitle: String, specialtyCategoryName: SpecialtyTags) {
////        let originalTagView = SpecialtyTagView(tagTitle: originalTagTitle, specialtyTagTitle: specialtyCategoryName.rawValue)
////        let newTag = Tag(title: newTagTitle, specialtyCategoryTitle: specialtyCategoryName)
////        let tagToDelete = replaceTag(originalTagView, newTag: newTag, tagArray: &tagChoicesDataArray)
////        //remove the previous tag from the actual backend
////        //TODO: this will be done, without the user knowing if the removal was actually completed. Probably should change that. My other stuff is saving when I hit the done button, so I should also delete when the done button is hit.
////        tagToDelete?.deleteInBackground()
////        if let originalTagView = tagChoicesView.findTagView(originalTagTitle, categoryName: specialtyCategoryName.rawValue) {
////            originalTagView.setTitle(newTagTitle, forState: .Normal)
////        }
////        chosenTagArray.append(newTag)
////        tagChoicesView.layoutSubviews()
//    }
}

extension FilterTagViewController: SpecialtyTagEnviromentHolderViewDelegate {
    func unhideChoicesTagListView() {
        createSpecialtyTagEnviroment(false)
    }
    
    //need to override this in addToProfileViewController class
    func createNewPersonalTag(title: String) {}
}

//tag helper extensions 
extension FilterTagViewController : TagListViewDelegate {
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 2 {
            //we are dealing with ChosenTagListView because I set the tag in storyboard to be 2
            sender.removeTagView(tagView)
            scrollViewSearchView.rearrangeSearchArea(tagView, extend: false)
            if let specialtyCategoryTitle = tagView.isFromSpecialtyCategory() {
                theSpecialtyChosenTagDictionary[specialtyCategoryTitle] = nil
            } else {
                if let index = theGenericChosenTagArray.indexOf(title) {
                        theGenericChosenTagArray.removeAtIndex(index)
                }
            }
        }
    }
}

extension FilterTagViewController : ChachaTagDropDownDelegate {
    func moveChoicesTagListViewDown(moveDown: Bool, animationDuration: NSTimeInterval, springWithDamping: CGFloat, initialSpringVelocity: CGFloat, downDistance: CGFloat?) {
        if moveDown {
            if let downDistance = downDistance {
                tagChoicesViewTopConstraint.constant = downDistance
            }
            tagChoicesView.shouldRearrangeViews = false
            UIView.animateWithDuration(
                animationDuration,
                delay: 0,
                usingSpringWithDamping: springWithDamping,
                initialSpringVelocity: initialSpringVelocity,
                options: [],
                animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil
            )
        } else {
            //we want to move the TagListView back up to original position, which is 0
            tagChoicesViewTopConstraint.constant -= tagChoicesViewTopConstraint.constant
            tagChoicesView.shouldRearrangeViews = false
            UIView.animateWithDuration(
                animationDuration,
                delay: 0,
                usingSpringWithDamping: springWithDamping,
                initialSpringVelocity: initialSpringVelocity,
                options: [],
                animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (_) in
                    self.tagChoicesView.shouldRearrangeViews = true
            })
        }
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
        if !scrollViewSearchView.theTagChosenListView.tagViews.isEmpty {
            //there are tags in the chosen area, so we want to go back to scroll view search area, not the normal search area
            scrollViewSearchView.hideScrollSearchView(false)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.showsCancelButton = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        fatalError("This method must be overridden in subclasses")
    }
    
    func resetTagChoicesViewList() {
        tagChoicesView.removeAllTags()
        loadChoicesViewTags()
        createSpecialtyTagEnviroment(false)
        theSpecialtyTagEnviromentHolderView?.removeFromSuperview()
    }
}





