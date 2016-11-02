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
    var chosenTags: [Tag] = []
    @IBOutlet weak var theTagScrollView: UIScrollView!
    var theBottomUserArea: BottomUserScrollView?
    
    var dataStore : SearchTagsDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewSearchView = addSearchScrollView(navigationController!.navigationBar)
        setDataFromDataStore()
        tagChoicesView.delegate = self
        scrollViewSearchView.scrollViewSearchViewDelegate = self
    }
    
    func setDataFromDataStore() {
        dataStore = SearchTagsDataStore(delegate: self) //sets the data for the tag arrays
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
            //TODO: use the parse column name or something for the height value, so when we change the height value, we don't have to worry about this breaking
            if dropDownTag.specialtyCategory == "Height" {
                //The height slider needs to show something like: 4'10" - 6'5", so it needs some special logic to do that. 
                dropDownMenu.addSlider(dropDownTag.minValue, maxValue: dropDownTag.maxValue, suffix: dropDownTag.suffix, isRangeSlider: dropDownTag.dropDownAttribute == .rangeSlider, isHeightSlider: true, sliderDelegate: self)
            } else {
                dropDownMenu.addSlider(dropDownTag.minValue, maxValue: dropDownTag.maxValue, suffix: dropDownTag.suffix, isRangeSlider: dropDownTag.dropDownAttribute == .rangeSlider, sliderDelegate: self)
            }
        default:
            break
        }
    }
    
    override func passSearchResults(searchTags: [Tag]) {
        tagChoicesView.removeAllTags()
        if searchTags.isEmpty {
            //TODO: there were no results from the search
            //TODO: If we can't find any more tags here, then stop querying any farther if the suer keeps typing
        } else {
            for (index, tag) in searchTags.enumerated() {
                let tagView = tagChoicesView.addTag(tag.title)
                if index == 0 {
                    //we want the first TagView in search area to be selected, so then you click search, and it adds to search bar. like 8tracks.
                    tagView.isSelected = true
                }
            }
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
            tappedDropDownTagView = dropDownTagView
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
            //TODO: figure out how to remove a slidervalue tag. Normal tags are only added when a search occurs
        }
    }
    
    //Purpose: I want to add a tag to the chosen view, have the search bar disappear to show all the chosen tags
    func addTagToChosenTagListView(_ title: String) {
        let tagView = tagChosenView.addTag(title)
        scrollViewSearchView?.rearrangeSearchArea(tagView, extend: true)
        scrollViewSearchView.hideScrollSearchView(false) //making the search bar disappear in favor of the scrolling area for the tagviews. like 8tracks does.
        showSuccessiveTags()
    }
    
    fileprivate func showSuccessiveTags() {
        tagChoicesView.removeAllTags()
        addChosenTagsToArray()
        dataStore.retrieveSuccessiveTags(chosenTags: chosenTags)
    }
}

extension SearchTagsViewController: ScrollViewSearchViewDelegate {
    //TODO: pass user array and also create custom segue for the single page animation of doing searches.
    func dismissPageAndPassUserArray() {
        addChosenTagsToArray()
        dataStore.findUserArray(chosenTags: chosenTags)
    }
    
    //Purpose: we want to save the chosen tagViews into the chosenTag array, so then we can query on it.
    fileprivate func addChosenTagsToArray() {
        for tagView in tagChosenView.tagViews {
            if let tagTitle = tagView.currentTitle {
                let arrayAlreadyContains: Bool = chosenTags.testAll({ (tag: Tag) -> Bool in
                    return tag.title == tagTitle
                })
                if !arrayAlreadyContains {
                    let tag = Tag(title: tagTitle, attribute: .generic)
                    chosenTags.append(tag)
                }
            }
        }
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
    func sliderValueChanged(text: String, minValue: Int, maxValue: Int, suffix: String) {
        scrollViewSearchView.hideScrollSearchView(false)
        if let tagView = findTagViewWithSuffix(suffix) {
            //the tagView has already been created
            //TODO: make the sliderView scroll over to where the tag is because if it is off the screen, then the user can't see it.
            tagView.setTitle(text, for: UIControlState())
            if let index = findIndexOfDropDownTag(suffix: suffix) {
                //replace the index of the dropDownTag with our updated dropDownTag
                let dropDownTag = chosenTags[index] as! DropDownTag
                dropDownTag.minValue = minValue
                dropDownTag.maxValue = maxValue
                dropDownTag.title = text
                dropDownTag.suffix = suffix
                chosenTags[index] = dropDownTag
            }
        } else {
            //tagView has never been created
            let tagView = tagChosenView.addTag(text)
            scrollViewSearchView.rearrangeSearchArea(tagView, extend: true)
            if let dropDownTagView = tappedDropDownTagView {
                //It doesn't really matter what dropDownAttribute we pass
                let tag = DropDownTag(specialtyCategory: dropDownTagView.specialtyCategoryTitle, minValue: minValue, maxValue: maxValue, suffix: suffix, dropDownAttribute: .singleSlider)
                tag.title = text
                chosenTags.append(tag)
            }
        }
    }
    
    func findIndexOfDropDownTag(suffix: String) -> Int? {
        if let index = chosenTags.index(where: { (tag: Tag) -> Bool in
            if let dropDownTag = tag as? DropDownTag, dropDownTag.suffix == suffix {
                return true
            }
            return false
        }) {
            return index
        }
        return nil
    }
    
    func findDropDownTag(suffix: String, array: [Tag]) -> DropDownTag? {
        for tag in array {
            if let dropDownTag = tag as? DropDownTag , dropDownTag.suffix == suffix {
                return dropDownTag
            }
        }
        return nil
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
    //TODO: can probably get rid of all these searchActive stuff, because I am not actually using them for anything
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            //no text, so we want to stay on the tagChoicesView
            searchActive = false
            resetTagChoicesViewList()
        } else {
            dataStore.searchForTags(searchText: searchText)
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

