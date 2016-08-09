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
    
    var dataStore : FilterQueryDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDataFromDataStore()
        tagChoicesView.delegate = self
        scrollViewSearchView.scrollViewSearchViewDelegate = self
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

//extension for tag actions
extension FilterQueryViewController {
    func specialtyTagPressed(title: String, tagView: SpecialtyTagView, sender: TagListView) {
        let tagAttribute = convertTagAttributeFromCategoryTitle(tagView.specialtyCategoryTitle)
        switch tagAttribute {
        case .SpecialtyTagMenu:
            let titleArray = tagView.specialtyCategoryTitle.specialtyTagTitles.map{$0.toString} //making the array into a string
            dropDownMenu.show(titleArray)
            dropDownMenu.tagListView.delegate = self
        default:
            break
        }
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        guard sender is ChachaChosenTagListView else {
            //making sure the sender TagListView is not the chosenView because the chosen view should not be clickable
            let tagView = tagChosenView.addTag(title)
            sender.removeTag(title)
            scrollViewSearchView?.rearrangeSearchArea(tagView, extend: true)
            scrollViewSearchView.hideScrollSearchView(false) //making the search bar disappear in favor of the scrolling area for the tagviews. like 8tracks does.
            return
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
            case .SearchPageToTinderMainPageSegue:
                //we had to pass the user array in prepareForSegue because I tried to use delegate function, but the view controller wasn't loaded, so the user array was just being reset.
                //the sender parameter is passed the user array
                let navigationVC = segue.destinationViewController as! ChachaNavigationViewController
                let rootVC = navigationVC.viewControllers[0] as! BackgroundAnimationViewController
                rootVC.userArray = sender as! [User]
        }
    }
}

