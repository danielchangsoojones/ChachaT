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
    
    //constraints
    @IBOutlet weak var theTagScrollViewTopConstraint: NSLayoutConstraint!
    
    
    var theBottomUserArea: BottomUserScrollView?
    
    var dataStore : SearchTagsDataStore!
    
    var theTappedCellIndex: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewSearchView = addSearchScrollView(navigationController!.navigationBar)
        spacingSetup()
        setDataFromDataStore()
        anonymousUserSetup()
        tagChoicesView.delegate = self
        scrollViewSearchView.scrollViewSearchViewDelegate = self
    }
    
    func spacingSetup() {
        theTagScrollViewTopConstraint.constant = TagViewProperties.marginY
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
            transformSearchBarForSlider()
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
            if sender.tag == 3 {
                //we are dealing with the ChachaDropDownTagListView
                dropDownMenu.hide()
            }
            return
        }
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 2 {
            //we are dealing with ChosenTagListView because I set the tag in storyboard to be 2
            removeTag(tagView: tagView, tagListView: sender)
            updateAfterTagChosen()
        }
    }
    
    func removeTag(tagView: TagView, tagListView: TagListView) {
        tagListView.removeTagView(tagView)
        removeTagFromChosenTags(title: tagView.currentTitle ?? "")
        scrollViewSearchView.rearrangeSearchArea(tagView, extend: false)
    }
    
    fileprivate func removeTagFromChosenTags(title: String) {
        //we don't technically save generic tags, but if we saved a slider tag, this would remove it from the chosen tag by matching the titles
        chosenTags = chosenTags.filter({ (tag: Tag) -> Bool in
            return tag.title != title
        })
    }
    
    //Purpose: I want to add a tag to the chosen view, have the search bar disappear to show all the chosen tags
    func addTagToChosenTagListView(_ title: String) {
        let tagView = tagChosenView.addTag(title)
        scrollViewSearchView?.rearrangeSearchArea(tagView, extend: true)
        scrollViewSearchView.hideScrollSearchView(false) //making the search bar disappear in favor of the scrolling area for the tagviews. like 8tracks does.
        updateAfterTagChosen()
    }
    
    //TODO: probably should rename this to something better of a name if you can think of one
    func updateAfterTagChosen() {
        resetTagChoicesViewList()
        //adding and then clearing the chosenTags array because we want to get the chosen tags for the searching, but then get rid of them because we don't track the chosen tags the whole time, only when an action is pressed. We do track the sliderValues in chosen tags though.
        addChosenTagsToArray()
        scrollViewSearchView.endEditing(true)
        dataStore.getSwipesForBottomArea(chosenTags: chosenTags)
        removeAllGenericTagsFromChosenTags()
    }
    
    fileprivate func removeAllGenericTagsFromChosenTags() {
        //We keepslider tags in the array because we store those in the chosenTag array the entire time.
        chosenTags = chosenTags.filter({ (tag: Tag) -> Bool in
            return tag.attribute != .generic
        })
    }
    
    func hideBottomUserArea() {
        toggleBottomUserArea(show: false)
        theTagScrollView.contentInset.bottom = 0
    }
    
    func toggleBottomUserArea(show: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
                //move the frame to the correct y position
            if show {
                self.theBottomUserArea?.frame.y -= self.theBottomUserArea?.frame.height ?? 0
            } else {
                //hiding the menu, push it off the screen
                self.theBottomUserArea?.frame.y = self.view.frame.maxY
            }
        })
    }
    
    func showBottomUserArea(swipes: [Swipe]) {
        theBottomUserArea = BottomUserScrollView(swipes: swipes, frame: CGRect(x: 0, y: self.view.frame.maxY, w: self.view.frame.width, h: self.view.frame.height / 3), delegate: self)
        self.view.addSubview(theBottomUserArea!)
        
        toggleBottomUserArea(show: true)
        
//        UIView.animate(withDuration: 0.5, animations: {
//            //move the frame to the correct y position
//            self.theBottomUserArea?.frame.y -= self.theBottomUserArea?.frame.height ?? 0
//        })
        
        theTagScrollView.contentInset.bottom = theBottomUserArea!.frame.height
    }
}

extension SearchTagsViewController: ScrollViewSearchViewDelegate {
    //TODO: pass user array and also create custom segue for the single page animation of doing searches.
    func dismissPageAndPassUserArray() {
        addChosenTagsToArray()
        dataStore.getSwipesForMainTinderPage(chosenTags: chosenTags)
    }
    
    //Purpose: we want to save the chosen tagViews into the chosenTag array, so then we can query on it.
    fileprivate func addChosenTagsToArray() {
        for tagView in tagChosenView.tagViews {
            if let tagTitle = tagView.currentTitle {
                var alreadyContains: Bool = false
                for tag in chosenTags where tag.title == tagTitle {
                    alreadyContains = true
                }
                if !alreadyContains {
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

extension SearchTagsViewController: EmptyStateDelegate {
    func emptyStateButtonPressed() {
        //Do something when they click the empty search button
        resetSearch()
    }
    
    func resetSearch() {
        for tagView in tagChosenView.tagViews {
            removeTag(tagView: tagView, tagListView: tagChosenView)
        }
        hideBottomUserArea()
    }
    
    func showEmptyState() {
        let emptyStateView = SearchingEmptyStateView(delegate: self)
        theBottomUserArea?.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func hideEmptyState() {
        for subview in theBottomUserArea?.subviews ?? [] {
            if subview is SearchingEmptyStateView {
                subview.removeFromSuperview()
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
                if let swipeArray = sender as? [Swipe] {
                    //the sender parameter is passed the user array
                    //but if the sender array was not passed a user array, then that means we just want to dimsiss the view controller without passing anything.
                    let navigationVC = segue.destination as! ChachaNavigationViewController
                    let rootVC = navigationVC.viewControllers[0] as! BackgroundAnimationViewController
                    rootVC.swipeArray = swipeArray
                    rootVC.prePassedSwipeArray = true
                }
        }
    }
}

