//
//  ScrollViewSearchView.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import UIKit

protocol ScrollViewSearchViewDelegate {
    func dismissPageAndPassUserArray()
    func dismissCurrentViewController()
}

class ScrollViewSearchView: UIView {
    
    @IBOutlet weak var theTagChosenListView: ChachaChosenTagListView!
    @IBOutlet weak var theTagChosenHolderView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var theSearchButton: UIButton!
    @IBOutlet weak var theGoButton: UIButton!
    @IBOutlet weak var theExitButton: UIButton!
    var searchBox: CustomTagsSearchBar!
    
    //constraint outlet
    @IBOutlet weak var theGoButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var theTagListViewWidthConstraint: NSLayoutConstraint!
    
    var searchBarDelegate: UISearchBarDelegate?
    var scrollViewSearchViewDelegate: ScrollViewSearchViewDelegate?
    
    var firstAppearance = true
    
    @IBAction func searchButtonTapped(sender: UIButton) {
        hideScrollSearchView(true)
    }
    
    @IBAction func goButtonTapped(sender: UIButton) {
        scrollViewSearchViewDelegate?.dismissPageAndPassUserArray()
    }
    
    @IBAction func exitButtonTapped(sender: UIButton) {
        scrollViewSearchViewDelegate?.dismissCurrentViewController()
    }
    
    func hideScrollSearchView(hide: Bool) {
        if firstAppearance {
            firstAppearance = false
        } else {
            //this is not the first time the searchBar is being shown
            toggleFirstResponder(hide)
        }
        theScrollView.hidden = hide
        searchBox.hidden = !hide
    }
    
    func toggleFirstResponder(becomeResponder: Bool) {
        if becomeResponder {
            searchBox.becomeFirstResponder()
        } else {
            resignFirstResponder()
            searchBox.text = ""
        }
    }
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clearColor() // for some reason, the background color was defaulting to white, and we want transparency
        setButtonBorders()
        searchBox = showSearchBox(self)
        hideScrollSearchView(true)
    }
    
    func showSearchBox(searchBoxHolder: UIView) -> CustomTagsSearchBar {
        let searchBox = CustomTagsSearchBar(placeHolderText: "Search Tags")
        searchBoxHolder.addSubview(searchBox)
        searchBox.snp_makeConstraints { (make) in
            make.edges.equalTo(searchBoxHolder)
        }
        return searchBox
    }
    
    func setButtonBorders() {
        let buttonArray = [theSearchButton, theGoButton, theExitButton]
        self.theGoButtonHeightConstraint.constant = TagView.getTagViewHeight(TagViewProperties.paddingY)
        for button in buttonArray {
            button.layer.cornerRadius = self.theGoButtonHeightConstraint.constant / 2
            button.layer.borderWidth = TagViewProperties.borderWidth
            button.layer.borderColor = TagViewProperties.borderColor.CGColor
        }
    }
    
    //Purpose: I want to be able to have a scroll view that grows/shrinks as tags are added to it.
    //TODO: I probably need to update the tagview to have remove button enabled.
    func rearrangeSearchArea(tagView: TagView, extend: Bool) {
        let tagWidth = tagView.intrinsicContentSize().width
        let tagPadding : CGFloat = self.theTagChosenListView.marginX
        //TODO: Not having the X remove button is not accounted for in the framework, so that was why the extension was not working because it was not including the X button.
        if extend {
            //we are adding a tag, and need to make more room
            self.theTagListViewWidthConstraint.constant += tagWidth + tagPadding
        } else {
            //deleting a tag, so shrink view
            self.theTagListViewWidthConstraint.constant -= tagWidth + tagPadding
        }
        
        self.layoutIfNeeded()
        //checking to see if tags have outgrown screen because then I want it to slide the newest tag into focus
        if self.frame.width <= theTagChosenHolderView.frame.width {
            //I want the scroll view to go to a content offset where I only see the newest added tags.
            //So, I find out how big the TagHolderViewWidth has grown. Then, I see how big the screen is, and the difference is the area that is off the screen.
            //Therefore, I want to have contentOffset start at the end of the area that has been pushed off screen.
            let screenWidth = self.frame.size.width
            let chosenTagHolderViewWidth = theTagChosenHolderView.frame.size.width
            theScrollView.setContentOffset(CGPointMake(chosenTagHolderViewWidth - screenWidth, 0), animated: true)
        }
    }
    
    class func instanceFromNib() -> ScrollViewSearchView {
        // the nibName has to match your class file and your xib file
        return UINib(nibName: "ScrollViewSearchView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ScrollViewSearchView
    }
}


