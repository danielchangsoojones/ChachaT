//
//  SearchTagsViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/21/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EFTools
import Parse

class SearchTagsViewController: SuperTagViewController {
    var tagChosenView : ChachaChosenTagListView!
    var scrollViewSearchView : ScrollViewSearchView!
    var theSpecialtyChosenTagDictionary : [SpecialtyCategoryTitles : TagView?] = [ : ] //holds the specialty tagviews, because they have specialty querying characteristics
    var theGenericChosenTagArray : [String] = []
    
    var dataStore : FilterQueryDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewSearchView = addSearchScrollView(navigationController!.navigationBar)
        setDataFromDataStore()
        setSpecialtyTagViewDictionary()
        tagChoicesView.delegate = self
        scrollViewSearchView.scrollViewSearchViewDelegate = self
    }
    
    func setDataFromDataStore() {
        dataStore = FilterQueryDataStore(delegate: self) //sets the data for the tag arrays
    }
    
    //the compiler was randomly crashing because it thought this function wasn't overriding super class. I think I had to put this function in main class instead of extension because compiler might look for overrided methods in extensions later.
    //It happens randomly.Or I could fix it by just getting rid of error creator in superclass
    override func loadChoicesViewTags() {
        for tagTitle in tagChoicesDataArray {
            if let specialtyCategoryTitle = SpecialtyCategoryTitles(rawValue: tagTitle) {
                //the tagTitle is special
                tagChoicesView.addSpecialtyTag(.GenderNone, specialtyCategoryTitle: specialtyCategoryTitle)
            } else {
                //just a generic tag. Right now, I am only adding specialtyTagCategories (Race, Hair Color) to the default view, but that could change
                tagChoicesView.addTag(tagTitle)
            }
        }
    }
    
    //You're probably thinking "Why not just set the variable in the global variable?" Well, it for some fucking reason, it has to be set like it is in this function, or else the nil is not being recognized by the == nil operator
    //no idea why, but this made it work.
    func setSpecialtyTagViewDictionary() {
        for category in SpecialtyCategoryTitles.allCategories {
            //seeding the dictionary with all the specialty category titles, and setting value to nil.
            theSpecialtyChosenTagDictionary[category] = nil
        }
    }
    
    func setChosenTagView(scrollViewSearchView: ScrollViewSearchView) {
        tagChosenView = scrollViewSearchView.theTagChosenListView
        tagChosenView.delegate = self
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//extension for tag actions
extension SearchTagsViewController : TagListViewDelegate {
    //TODO: for sliders, there needs to be the valueSuffix in the tag enum file.
    func specialtyTagPressed(title: String, tagView: SpecialtyTagView, sender: TagListView) {
        let specialtyCategoryTitle = tagView.specialtyCategoryTitle
        if let tagAttribute = specialtyCategoryTitle.associatedTagAttribute {
            switch tagAttribute {
            case .SpecialtyTagMenu:
                let titleArray = specialtyCategoryTitle.specialtyTagTitles.map{$0.toString} //making the array into a string
                dropDownMenu.showTagListView(titleArray, specialtyCategoryTitle: specialtyCategoryTitle)
                dropDownMenu.tagListView!.delegate = self
            case .SpecialtySingleSlider:
                var valueSuffix = ""
                if title == SpecialtyCategoryTitles.Location.rawValue {
                    //they are trying to use location tag, we want to check they have location enabled
                    //the user has to have location enabled in order to use this tag
                    PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint, error) in
                        if let geoPoint = geoPoint where error == nil {
                            //saving location in two places in database because it makes easier querying with the tags.
                            User.currentUser()!.location = geoPoint
                            PFObject.saveAllInBackground([User.currentUser()!], block: nil)
                        } else {
                            print(error)
                        }
                    })
                    valueSuffix = " mi"
                }
                dropDownMenu.showSingleSliderView()
                dropDownMenu.singleSliderView?.setDelegateAndCreateTagView(self, specialtyCategoryTitle: specialtyCategoryTitle, valueSuffix: valueSuffix)
            case .SpecialtyRangeSlider:
                dropDownMenu.showRangeSliderView(self, dropDownMenuCategoryType: specialtyCategoryTitle)
            }
        }
    }
    
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        guard sender is ChachaChosenTagListView else {
            //making sure the sender TagListView is not the chosenView because the chosen view should not be clickable. as in the dropdown menu tags or the tagChoicesView
            addTagToChosenTagListView(title)
            return
        }
    }
    
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

extension SearchTagsViewController: ScrollViewSearchViewDelegate {
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
        dataStore.findUserArray(theGenericChosenTagArray, specialtyTagDictionary: theSpecialtyChosenTagDictionary)
    }
    
    func dismissCurrentViewController() {
        //TODO: cache the user array from the previous search, so then we can just reupload that user array because the user hit exit, which means they canceled their search.
        //Right Now, I am just sending empty user array, so it will work. 
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: [])
    }
    
    func scrollViewSearchViewTapOccurred() {
        dropDownMenu.hide()
    }
}

//search extension
extension SearchTagsViewController : UISearchBarDelegate {
   func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let filtered : [String] = filterArray(searchText, searchDataArray: searchDataArray)
        tagChoicesView.removeAllTags()
        if searchText.isEmpty {
            //no text, so we want to stay on the tagChoicesView
            searchActive = false
            resetTagChoicesViewList()
        } else if(filtered.count == 0){
            //there is text, but it has no matches in the database
        } else {
            //there is text, and we have a match, soa the tagChoicesView changes accordingly
            searchActive = true
            for (index, tagTitle) in filtered.enumerate() {
                let tagView = tagChoicesView.addTag(tagTitle)
                if index == 0 {
                    //we want the first TagView in search area to be selected, so then you click search, and it adds to search bar. like 8tracks.
                    tagView.selected = true
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        resetTagChoicesViewList()
        if !scrollViewSearchView.theTagChosenListView.tagViews.isEmpty {
            //there are tags in the chosen area, so we want to go back to scroll view search area, not the normal search area
            scrollViewSearchView.hideScrollSearchView(false)
        }
        if tagChosenView.tagViews.isEmpty {
            performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: nil)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        for tagView in tagChoicesView.selectedTags() {
            if let currentTitle = tagView.currentTitle {
                addTagToChosenTagListView(currentTitle)
            }
        }
    }
}

extension SearchTagsViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case SearchPageToTinderMainPageSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
            case .SearchPageToTinderMainPageSegue:
                //we had to pass the user array in prepareForSegue because I tried to use delegate function, but the view controller wasn't loaded, so the user array was just being reset.
                if let userArray = sender as? [User] {
                    //the sender parameter is passed the user array
                    //but if the sender array was not passed a user array, then that means we just want to dimsiss the view controller without passing anything.
                    let navigationVC = segue.destinationViewController as! ChachaNavigationViewController
                    let rootVC = navigationVC.viewControllers[0] as! BackgroundAnimationViewController
                    rootVC.userArray = userArray
                }
        }
    }
}

