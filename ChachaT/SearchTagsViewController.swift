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
    //TODO: this dictionary should really be in the dataStore. We want to keep our API dependency seperate from the actual class.
    var theSpecialtyChosenTagDictionary : [SpecialtyCategoryTitles : TagView?] = [ : ] //holds the specialty tagviews, because they have specialty querying characteristics
    var theGenericChosenTagArray : [String] = []
    
    var dataStore : SearchTagsDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewSearchView = addSearchScrollView(navigationController!.navigationBar)
        setDataFromDataStore()
        setSpecialtyTagViewDictionary()
        tagChoicesView.delegate = self
        scrollViewSearchView.scrollViewSearchViewDelegate = self
    }
    
    func setDataFromDataStore() {
        dataStore = SearchTagsDataStore(delegate: self) //sets the data for the tag arrays
    }
    
    //You're probably thinking "Why not just set the variable in the global variable?" Well, it for some fucking reason, it has to be set like it is in this function, or else the nil is not being recognized by the == nil operator
    //no idea why, but this made it work.
    func setSpecialtyTagViewDictionary() {
        for category in SpecialtyCategoryTitles.allCategories {
            //seeding the dictionary with all the specialty category titles, and setting value to nil.
            theSpecialtyChosenTagDictionary[category] = nil
        }
    }
    
    func setChosenTagView(_ scrollViewSearchView: ScrollViewSearchView) {
        tagChosenView = scrollViewSearchView.theTagChosenListView
        tagChosenView.delegate = self
    }
    
    func addSearchScrollView(_ holderView: UIView) -> ScrollViewSearchView {
        //getting the xib file for the scroll view
        let scrollViewSearchView = ScrollViewSearchView.instanceFromNib()
        scrollViewSearchView.searchBox.delegate = self
        self.navigationController?.navigationBar.addSubview(scrollViewSearchView)
        scrollViewSearchView.snp.makeConstraints { (make) in
            make.edges.equalTo((self.navigationController?.navigationBar)!)
        }
        setChosenTagView(scrollViewSearchView)
        return scrollViewSearchView
    }
    
    override func dropDownActions(_ dropDownTag: DropDownTag) {
        super.dropDownActions(dropDownTag)
        switch dropDownTag.dropDownAttribute {
        case .rangeSlider, .singleSlider:
            dropDownMenu.addSlider(dropDownTag.minValue, maxValue: dropDownTag.maxValue, suffix: dropDownTag.suffix, isRangeSlider: dropDownTag.dropDownAttribute == .rangeSlider, sliderDelegate: self)
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//extension for tag actions
extension SearchTagsViewController {
    //TODO: for sliders, there needs to be the valueSuffix in the tag enum file.
    func specialtyTagPressed(_ title: String, tagView: SpecialtyTagView, sender: TagListView) {
        switch tagView.tagAttribute {
        case .dropDownMenu:
            let dropDownTagView = tagView as! DropDownTagView
            if let dropDownTag = findDropDownTag(dropDownTagView.specialtyCategoryTitle, array: tagChoicesDataArray) {
                dropDownActions(dropDownTag)
            }
        default:
            break
        }
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        guard sender is ChachaChosenTagListView else {
            //making sure the sender TagListView is not the chosenView because the chosen view should not be clickable. as in the dropdown menu tags or the tagChoicesView
            addTagToChosenTagListView(title)
            return
        }
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 2 {
            //we are dealing with ChosenTagListView because I set the tag in storyboard to be 2
            sender.removeTagView(tagView)
            scrollViewSearchView.rearrangeSearchArea(tagView, extend: false)
            if let specialtyCategoryTitle = tagView.isFromSpecialtyCategory() {
                theSpecialtyChosenTagDictionary[specialtyCategoryTitle] = nil
            } else {
                if let index = theGenericChosenTagArray.index(of: title) {
                    theGenericChosenTagArray.remove(at: index)
                }
            }
        }
    }
    
    //Purpose: I want to add a tag to the chosen view, have the search bar disappear to show all the chosen tags
    func addTagToChosenTagListView(_ title: String) {
        let tagView = tagChosenView.addTag(title)
        scrollViewSearchView?.rearrangeSearchArea(tagView, extend: true)
        scrollViewSearchView.hideScrollSearchView(false) //making the search bar disappear in favor of the scrolling area for the tagviews. like 8tracks does.
        resetTagChoicesViewList()
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
        let usersToPass: [User] = []
        performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: usersToPass as AnyObject?)
    }
    
    func scrollViewSearchViewTapOccurred() {
        dropDownMenu.hide()
    }
}

extension SearchTagsViewController: SliderViewDelegate {
    func sliderValueChanged(_ text: String, suffix: String) {
        scrollViewSearchView.hideScrollSearchView(false)
        if let tagView = findTagViewWithSuffix(suffix) {
            //the tagView has already been created
            //TODO: make the sliderView scroll over to where the tag is because if it is off the screen, then the user can't see it.
            tagView.setTitle(text, for: UIControlState())
            if let specialtyCategoryTitle = SpecialtyCategoryTitles.suffixRawValue(suffix: suffix) {
                theSpecialtyChosenTagDictionary[specialtyCategoryTitle] = tagView
            }
        } else {
            //tagView has never been created
            let tagView = tagChosenView.addTag(text)
            scrollViewSearchView.rearrangeSearchArea(tagView, extend: true)
            if let specialtyCategoryTitle = SpecialtyCategoryTitles.suffixRawValue(suffix: suffix) {
                theSpecialtyChosenTagDictionary[specialtyCategoryTitle] = tagView
            }
        }
    }
    
    //TODO: change this to work with a regex that checks if the given tagViewTitle works with a particular pattern.
    func findTagViewWithSuffix(_ suffix: String) -> TagView? {
        for tagView in tagChosenView.tagViews {
            //TODO: should get the tagView, not just based upon the suffix. Should check that the text is exactly how we would structure a numbered tagView
            if let currentTitle = tagView.currentTitle , currentTitle.hasSuffix(suffix) {
                return tagView
            }
        }
        return nil
    }
}

//search extension
extension SearchTagsViewController : UISearchBarDelegate {
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
            for (index, tagTitle) in filtered.enumerated() {
                let tagView = tagChoicesView.addTag(tagTitle)
                if index == 0 {
                    //we want the first TagView in search area to be selected, so then you click search, and it adds to search bar. like 8tracks.
                    tagView.isSelected = true
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
            case .SearchPageToTinderMainPageSegue:
                //we had to pass the user array in prepareForSegue because I tried to use delegate function, but the view controller wasn't loaded, so the user array was just being reset.
                if let userArray = sender as? [User] {
                    //the sender parameter is passed the user array
                    //but if the sender array was not passed a user array, then that means we just want to dimsiss the view controller without passing anything.
                    let navigationVC = segue.destination as! ChachaNavigationViewController
                    let rootVC = navigationVC.viewControllers[0] as! BackgroundAnimationViewController
                    var swipeArray: [Swipe] = []
                    for user in userArray {
                        //TODO: all the users won't technically be falsely approved
                        let swipe = Swipe(otherUser: user, otherUserApproval: false)
                        swipeArray.append(swipe)
                    }
                    rootVC.swipeArray = swipeArray
                    rootVC.prePassedSwipeArray = true
                }
        }
    }
}

