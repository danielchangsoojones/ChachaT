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

//this is a superclass for the tag querying page and the adding tags to profile page because they share many of the same values
class FilterTagViewController: UIViewController {
    
    @IBOutlet weak var tagChoicesView: ChachaChoicesTagListView!
    var tagChosenView : ChachaChosenTagListView!
    @IBOutlet weak var backgroundColorView: UIView!
    var scrollViewSearchView : ScrollViewSearchView!
    var dropDownMenu: ChachaDropDownMenu!
    
    //constraint outlets
    @IBOutlet weak var tagChoicesViewTopConstraint: NSLayoutConstraint!
    
    var searchDataArray: [String] = []
    var tagChoicesDataArray: [String] = []
    var theSpecialtyChosenTagDictionary : [SpecialtyCategoryTitles : TagView?] = [ : ] //holds the specialty tagviews, because they have specialty querying characteristics
    var theGenericChosenTagArray : [String] = []
    
    //search Variables
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        setDropDownMenu()
    }
    
    func loadChoicesViewTags() {
        fatalError("This method must be overridden in subclasses")
    }
    
    func addSearchScrollView(holderView: UIView) -> ScrollViewSearchView {
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
        dropDownMenu = ChachaDropDownMenu(containerView: (navigationController?.view)!, popDownOriginY: navigationBarHeight! + statusBarHeight, delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
    
    //Purpose: I want to add a tag to the chosen view, have the search bar disappear to show all the chosen tags
    func addTagToChosenTagListView(title: String) {
        let tagView = tagChosenView.addTag(title)
        scrollViewSearchView?.rearrangeSearchArea(tagView, extend: true)
        scrollViewSearchView.hideScrollSearchView(false) //making the search bar disappear in favor of the scrolling area for the tagviews. like 8tracks does.
        if let specialtyCategoryTitle = tagView.isFromSpecialtyCategory() {
            //the tagView pressed was a tag that is part of a specialtyCategory (like Democrat, Blonde, ect.)
            theSpecialtyChosenTagDictionary[specialtyCategoryTitle] = tagView
        } else {
            //just a generic tag pressed
            theGenericChosenTagArray.append(title)
        }
    }
}

extension FilterTagViewController : ChachaDropDownMenuDelegate {
    func moveChoicesTagListViewDown(moveDown: Bool, animationDuration: NSTimeInterval, springWithDamping: CGFloat, initialSpringVelocity: CGFloat, downDistance: CGFloat?) {
        if moveDown {
            if let downDistance = downDistance {
                tagChoicesViewTopConstraint.constant = downDistance
            }
            //we don't want the TagListView to rearrange every time the dropDown moves, that looks bad. 
            tagChoicesView.shouldRearrangeViews = false
            UIView.animateWithDuration(
                animationDuration,
                delay: 0,
                usingSpringWithDamping: springWithDamping,
                initialSpringVelocity: initialSpringVelocity,
                options: [],
                animations: {
                    self.view.layoutIfNeeded()
                    self.tagChoicesView.shouldRearrangeViews = true
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
        for tagView in tagChoicesView.selectedTags() {
            if let currentTitle = tagView.currentTitle {
                addTagToChosenTagListView(currentTitle)
            }
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        fatalError("This method must be overridden in subclasses")
    }
    
    func resetTagChoicesViewList() {
        tagChoicesView.removeAllTags()
        loadChoicesViewTags()
    }
}





