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

    var dropDownMenu: ChachaDropDownMenu!
    var tappedDropDownTagView : DropDownTagView? //a global variable to hold the dropDownTag that was tapped to pull down a ChachaDropDownMenu
    
    //constraint outlets
    @IBOutlet weak var tagChoicesViewTopConstraint: NSLayoutConstraint!
    
    var searchDataArray: [Tag] = []
    var tagChoicesDataArray: [Tag] = []
    
    //search Variables
    var searchActive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        setDropDownMenu()
    }
    
    func loadChoicesViewTags() {
        for tag in tagChoicesDataArray {
            switch tag.attribute {
            case .dropDownMenu:
                addDropDownTag(tag: tag)
            case .generic:
                _ = tagChoicesView.addTag(tag.title)
            default:
                break
            }
        }
    }
    
    func addDropDownTag(tag: Tag) {
        let dropDownTag = tag as! DropDownTag
        _ = tagChoicesView.addDropDownTag(dropDownTag.title, specialtyCategoryTitle: dropDownTag.specialtyCategory) as! DropDownTagView
    }
    
    func resetTagChoicesViewList() {
        tagChoicesView.removeAllTags()
        loadChoicesViewTags()
    }
    
    func setDropDownMenu() {
        let navigationBarHeight = navigationController?.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        if let navigationBarHeight = navigationBarHeight {
            dropDownMenu = ChachaDropDownMenu(containerView: self.view, popDownOriginY: navigationBarHeight + statusBarHeight, delegate: self)
        }
    }
    
    func dropDownActions(_ dropDownTag: DropDownTag) {
        switch dropDownTag.dropDownAttribute {
        case .tagChoices:
            dropDownMenu.addTagListView(dropDownTag.innerTagTitles, specialtyCategory: dropDownTag.specialtyCategory, tagListViewDelegate: self)
        default:
            break
        }
    }
    
    func passSearchResults(searchTags: [Tag]) {
        fatalError("Subclasses need to implement the `passSearchResults` method.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//dealing with the tagListView
extension SuperTagViewController : TagListViewDelegate {
    //Purpose: find the corresponding DropDownTag model to the DropDownTagView, which we find by matching the specialtyCategory titles.
    func findDropDownTag(_ specialtyCategory: String, array: [Tag]) -> DropDownTag? {
        for tag in array {
            if let dropDownTag = tag as? DropDownTag , dropDownTag.specialtyCategory == specialtyCategory {
                return dropDownTag
            }
        }
        return nil
    }
}

extension SuperTagViewController : ChachaDropDownMenuDelegate {
    func moveChoicesTagListViewDown(_ moveDown: Bool, animationDuration: TimeInterval, springWithDamping: CGFloat, initialSpringVelocity: CGFloat, downDistance: CGFloat) {
        if moveDown {
            tagChoicesViewTopConstraint.constant += downDistance
            //we don't want the TagListView to rearrange every time the dropDown moves, that looks bad.
            tagChoicesView.shouldRearrangeViews = false
            UIView.animate(
                withDuration: animationDuration,
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
            UIView.animate(
                withDuration: animationDuration,
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




