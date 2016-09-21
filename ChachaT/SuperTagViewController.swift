//
//  SuperTagViewController.swift
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
class SuperTagViewController: UIViewController {
    
    @IBOutlet weak var tagChoicesView: ChachaChoicesTagListView!
    @IBOutlet weak var backgroundColorView: UIView!

    var dropDownMenu: ChachaDropDownMenu!
    
    //constraint outlets
    @IBOutlet weak var tagChoicesViewTopConstraint: NSLayoutConstraint!
    
    var searchDataArray: [Tag] = []
    var tagChoicesDataArray: [Tag] = []
    
    //search Variables
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        setDropDownMenu()
    }
    
    func loadChoicesViewTags() {
        for tag in tagChoicesDataArray {
            switch tag.attribute {
            case .DropDownMenu:
                let dropDownTag = tag as! DropDownTag
                let tagView = tagChoicesView.addDropDownTag(dropDownTag.title, specialtyCategoryTitle: dropDownTag.specialtyCategory) as! DropDownTagView
                if dropDownTag.isPrivate {
                    tagView.makePrivate()
                }
            case .Generic:
                tagChoicesView.addTag(tag.title)
            }
        }
    }
    
    func resetTagChoicesViewList() {
        tagChoicesView.removeAllTags()
        loadChoicesViewTags()
    }
    
    func setDropDownMenu() {
        let navigationBarHeight = navigationController?.navigationBar.frame.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        if let navigationBarHeight = navigationBarHeight {
            dropDownMenu = ChachaDropDownMenu(containerView: self.view, popDownOriginY: navigationBarHeight + statusBarHeight, delegate: self)
        }
    }
    
    func dropDownActions(dropDownTag: DropDownTag) {
        switch dropDownTag.dropDownAttribute {
        case .TagChoices:
            dropDownMenu.addTagListView(dropDownTag.innerTagTitles, specialtyCategory: dropDownTag.specialtyCategory, tagListViewDelegate: self)
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//dealing with the tagListView
extension SuperTagViewController : TagListViewDelegate {
    //Purpose: find the corresponding DropDownTag model to the DropDownTagView, which we find by matching the specialtyCategory titles.
    func findDropDownTag(specialtyCategory: String, array: [Tag]) -> DropDownTag? {
        for tag in array {
            if let dropDownTag = tag as? DropDownTag where dropDownTag.specialtyCategory == specialtyCategory {
                return dropDownTag
            }
        }
        return nil
    }
}

extension SuperTagViewController : ChachaDropDownMenuDelegate {
    func moveChoicesTagListViewDown(moveDown: Bool, animationDuration: NSTimeInterval, springWithDamping: CGFloat, initialSpringVelocity: CGFloat, downDistance: CGFloat) {
        if moveDown {
            tagChoicesViewTopConstraint.constant += downDistance
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
            tagChoicesViewTopConstraint.constant -= downDistance
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

//search functionality
extension SuperTagViewController {
    func filterArray(searchText: String, searchDataArray: [Tag]) -> [String] {
        var filtered:[String] = []
        let searchDataTitleArray: [String] = searchDataArray.map {
            $0.title
        }
        filtered = searchDataTitleArray.filter({ (tagTitle) -> Bool in
            //finds the tagTitle, but if nil, then uses the specialtyTagTitle
            //TODO: have to make sure if the specialtyTagTitle is nil, then it goes the specialtyCategoryTitel
            let tmp: NSString = tagTitle
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        return filtered
    }
}

protocol TagDataStoreDelegate {
    func setSearchDataArray(searchDataArray: [Tag])
    func setChoicesViewTagsArray(tagChoicesDataArray: [Tag])
}

extension SuperTagViewController : TagDataStoreDelegate {
    func setSearchDataArray(searchDataArray: [Tag]) {
        self.searchDataArray = searchDataArray
    }
    
    func setChoicesViewTagsArray(tagChoicesDataArray: [Tag]) {
        //TODO: is alphabetizing going to take a long time, should I just be saving them alphabetically?
        let alphabeticallySortedArray = tagChoicesDataArray.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == NSComparisonResult.OrderedAscending }
        self.tagChoicesDataArray = alphabeticallySortedArray
        loadChoicesViewTags()
    }
}




