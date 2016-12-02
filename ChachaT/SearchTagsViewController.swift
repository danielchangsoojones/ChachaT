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
import Instructions
import EZSwiftExtensions

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
    
    let coachMarksController = CoachMarksController()
    var showTutorial: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewSearchView = addSearchScrollView(navigationController!.navigationBar)
        spacingSetup()
        setDataFromDataStore()
        tagChoicesView.delegate = self
        scrollViewSearchView.scrollViewSearchViewDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpTutorialCoachingMarks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coachMarksController.stop(immediately: true)
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
    
    override func loadChoicesViewTags() {
        if !showTutorial {
            super.loadChoicesViewTags()
        }
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
        //Technically, just need to remove the no tag exist label subview, not all subviews, it just so happens that the only subview left is the label.
        tagChoicesView.removeSubviews() //in case we have added the "No tags exist" label
        if searchTags.isEmpty {
            let label = UILabel()
            label.textColor = CustomColors.SilverChaliceGrey
            label.textAlignment = .center
            label.text = "No tag exists"
            tagChoicesView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.centerX.equalTo(self.view)
                make.top.equalTo(tagChoicesView).offset(10)
            })
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
    
    override func getMostCurrentSearchText() -> String {
        return scrollViewSearchView.getSearchBarText() ?? ""
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
            let wasSearchActive: Bool = searchActive //searchActive changes halfway through func, so this holds its original value
            //making sure the sender TagListView is not the chosenView because the chosen view should not be clickable. as in the dropdown menu tags or the tagChoicesView
            if sender.tag == 3 {
                //we are dealing with the ChachaDropDownTagListView
                dropDownMenu.hide()
            } else if sender.tag == 1 {
                //the tagChoicesListView
                sender.removeTag(title)
            }
            chosenTags.append(Tag(title: title, attribute: .generic))
            addTagToChosenTagListView(title)
            updateAfterTagChosen()
            if wasSearchActive && sender.tag == 1 {
                //we only want to resetTagChoicesView after the tag has been added to the chosenArea, if we do it beforehand, we get lag time.
                self.resetTagChoicesViewList()
            }
            return
        }
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 2 {
            //we are dealing with ChosenTagListView because I set the tag in storyboard to be 2
            removeTag(tagView: tagView, tagListView: sender)
            dataStore.removeSearchTags(chosenTags: chosenTags)
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
        scrollViewSearchView.endEditing(true)
    }
    
    //TODO: probably should rename this to something better of a name if you can think of one
    func updateAfterTagChosen() {
        dataStore.searchTags(chosenTags: chosenTags)
    }
}

extension SearchTagsViewController: ScrollViewSearchViewDelegate {
    //TODO: pass user array and also create custom segue for the single page animation of doing searches.
    func dismissPageAndPassUserArray() {
        //TODO: fix the dismissing of the page, we should already be loaded by the time they hit this.
        dataStore.getSwipesForMainTinderPage(chosenTags: chosenTags)
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
        if !scrollViewSearchView.theTagChosenListView.tagViews.isEmpty {
            //there are tags in the chosen area, so we want to go back to scroll view search area, not the normal search area
            resetTagChoicesViewList()
            scrollViewSearchView.hideScrollSearchView(false)
        }
        if tagChosenView.tagViews.isEmpty {
            performSegueWithIdentifier(.SearchPageToTinderMainPageSegue, sender: nil)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        for tagView in tagChoicesView.selectedTags() {
            tagChoicesView.tagPressed(tagView)
        }
        searchActive = false
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
                let navigationVC = segue.destination as! ChachaNavigationViewController
                let rootVC = navigationVC.viewControllers[0] as! BackgroundAnimationViewController
                
                if let swipeArray = sender as? [Swipe] {
                    //we had to pass the swipe array in prepareForSegue because I tried to use delegate function, but the view controller wasn't loaded, so the user array was just being reset.
                    rootVC.prePassedSwipeArray = true
                    rootVC.swipeArray = swipeArray
                }
        }
    }
}

