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
    var dataStore : FilterQueryDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDataFromDataStore()
        tagChoicesView.delegate = self
        scrollViewSearchView.scrollViewSearchViewDelegate = self
//        let navigationBarHeight = navigationController?.navigationBar.frame.height
//        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        //this bottom is just for testing
//        self.menuView = ChachaTagDropDown(containerView: (navigationController?.view)!, tags: [Tag(title: "hi", specialtyCategoryTitle: nil)], popDownOriginY: navigationBarHeight! + statusBarHeight, delegate: self)
    }
    
    func setDataFromDataStore() {
        dataStore = FilterQueryDataStore(delegate: self) //sets the data for the tag arrays
    }
    
    //the compiler was randomly crashing because it thought this function wasn't overriding super class. I think I had to put this function in main class instead of extension because compiler might look for overrided methods in extensions later.
    //It happens randomly.Or I could fix it by just getting rid of error creator in superclass
    override func loadChoicesViewTags() {
        for tag in tagChoicesDataArray {
            if tag.isGeneric() {
                tagChoicesView.addTag(tag.title!)
            } else if let tagTuple = tag.isSpecial() {
                tagChoicesView.addSpecialtyTag(tagTuple.specialtyTagTitle, specialtyCategoryTitle: tagTuple.specialtyCategoryTitle)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FilterQueryViewController : ChachaTagDropDownDelegate {
    func moveChoicesTagListViewDown(moveDown: Bool, animationDuration: NSTimeInterval, springWithDamping: CGFloat, initialSpringVelocity: CGFloat, downDistance: CGFloat?) {
        if moveDown {
            if let downDistance = downDistance {
                tagChoicesViewTopConstraint.constant = downDistance
            }
            tagChoicesView.shouldRearrangeViews = false
            UIView.animateWithDuration(
                animationDuration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
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

//setting default tags in view extension
extension FilterQueryViewController {
}


//extension for tag actions
extension FilterQueryViewController {
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        if let tag = findTag(tagView, tagArray: tagChoicesDataArray) {
            switch tag.attribute {
            case TagAttributes.Generic.rawValue:
                break
//                let tagView = tagChosenView.addTag(tag.title)
//                tagChoicesView.removeTag(tag.title)
//                scrollViewSearchView?.rearrangeSearchArea(tagView!, extend: true)
            case TagAttributes.SpecialtyTagMenu.rawValue:
                break
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
}

extension FilterQueryViewController: ScrollViewSearchViewDelegate {
    //TODO: pass user array and also create custom segue for the single page animation of doing searches.
    func dismissPageAndPassUserArray() {
        var chosenTagArrayTitles : [String] = []
        if let scrollViewSearchView = scrollViewSearchView {
            for tagView in scrollViewSearchView.theTagChosenListView.tagViews {
                if let titleLabel = tagView.titleLabel {
                    if let title = titleLabel.text {
                        //need to get title array because I want to do contained in query, which requires strings
                        chosenTagArrayTitles.append(title)
                    }
                }
            }
        }
        dataStore.findUserArray(chosenTagArrayTitles)
    }
    
    func dismissCurrentViewController() {
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: self)
    }
}

//search extension
extension FilterQueryViewController {
   override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var filtered:[Tag] = []
        tagChoicesView.removeAllTags()
        filtered = searchDataArray.filter({ (tag) -> Bool in
            //finds the tagTitle, but if nil, then uses the specialtyTagTitle
            //TODO: have to make sure if the specialtyTagTitle is nil, then it goes the specialtyCategoryTitel
            let tmp: NSString = tag.titleToShowForTag()
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
            //there is text, and we have a match, soa the tagChoicesView changes accordingly
            searchActive = true
            for tag in filtered {
                tagChoicesView.addTag(tag.titleToShowForTag())
            }
            createSpecialtyTagEnviroment(false)
        }
    }
}

extension FilterQueryViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case SearchPageToTinderMainPageSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        default: break
        }
    }
}

