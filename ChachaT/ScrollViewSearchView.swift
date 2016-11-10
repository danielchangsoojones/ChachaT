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
    func scrollViewSearchViewTapOccurred()
}

class ScrollViewSearchView: UIView {
    fileprivate struct SearchViewConstants {
        static let edgeInset: CGFloat = 10
        static let imageEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: SearchViewConstants.edgeInset, left: SearchViewConstants.edgeInset, bottom: SearchViewConstants.edgeInset, right: SearchViewConstants.edgeInset)
    }
    
    @IBOutlet weak var theTagChosenListView: ChachaChosenTagListView!
    @IBOutlet weak var theTagChosenHolderView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var theSearchButton: UIButton!
    @IBOutlet weak var theGoButton: UIButton!
    @IBOutlet weak var theExitButton: UIButton!
    @IBOutlet weak var theButtonStackView: UIStackView!
    @IBOutlet weak var theFinishedButtonsStackView: UIStackView!
    
    var searchBox: CustomTagsSearchBar!
    
    //constraint outlet
    @IBOutlet weak var theGoButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var theTagListViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var theLeadingSearchButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var theTrailingSearchButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var theTrailingFinishedStackViewConstraint: NSLayoutConstraint!
    
    
    var searchBarDelegate: UISearchBarDelegate?
    var scrollViewSearchViewDelegate: ScrollViewSearchViewDelegate?
    
    var firstAppearance = true
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        hideScrollSearchView(true)
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        scrollViewSearchViewDelegate?.dismissPageAndPassUserArray()
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        scrollViewSearchViewDelegate?.dismissCurrentViewController()
    }
    
    func hideScrollSearchView(_ hide: Bool) {
        if firstAppearance {
            firstAppearance = false
        } else {
            //this is not the first time the searchBar is being shown
            toggleFirstResponder(hide)
        }
        theScrollView.isHidden = hide
        theFinishedButtonsStackView.isHidden = hide
        searchBox.isHidden = !hide
    }
    
    func toggleFirstResponder(_ becomeResponder: Bool) {
        if becomeResponder {
            searchBox.becomeFirstResponder()
        } else {
            resignFirstResponder()
            searchBox.text = ""
        }
    }
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear // for some reason, the background color was defaulting to white, and we want transparency
        setButtonBorders()
        buttonsSetup()
        searchBox = showSearchBox(self)
        hideScrollSearchView(true)
    }
    
    func buttonsSetup() {
        theGoButton.imageEdgeInsets = SearchViewConstants.imageEdgeInsets
        theExitButton.imageEdgeInsets = SearchViewConstants.imageEdgeInsets
        setProperSpacing()
    }
    
    fileprivate func setProperSpacing() {
        let spacing = theTagChosenListView.marginX
        theLeadingSearchButtonConstraint.constant = spacing
        theTrailingSearchButtonConstraint.constant = spacing
        theFinishedButtonsStackView.spacing = spacing
        theTrailingFinishedStackViewConstraint.constant = spacing
    }
    
    func showSearchBox(_ searchBoxHolder: UIView) -> CustomTagsSearchBar {
        let searchBox = CustomTagsSearchBar(placeHolderText: "Search Tags")
        searchBoxHolder.addSubview(searchBox)
        searchBox.snp.makeConstraints { (make) in
            make.trailing.top.bottom.equalTo(searchBoxHolder)
            make.leading.equalToSuperview().inset(theLeadingSearchButtonConstraint.constant)
        }
        return searchBox
    }
    
    func setButtonBorders() {
        let buttonArray = [theSearchButton, theGoButton, theExitButton]
        self.theGoButtonHeightConstraint.constant = TagView.getTagViewHeight(TagViewProperties.paddingY)
        
        for button in buttonArray {
            button?.layer.cornerRadius = (self.theGoButtonHeightConstraint.constant / 2)
            button?.layer.borderWidth = TagViewProperties.borderWidth
            button?.layer.borderColor = TagViewProperties.borderColor.cgColor
        }
    }
    
    //Purpose: I want to be able to have a scroll view that grows/shrinks as tags are added to it.
    //TODO: I probably need to update the tagview to have remove button enabled.
    func rearrangeSearchArea(_ tagView: TagView, extend: Bool) {
        let tagWidth = tagView.intrinsicContentSize.width
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
        //checking to see if tags have reached the last buttons because then I want it to slide the newest tag into focus
        if theFinishedButtonsStackView.frame.x <= theTagChosenHolderView.frame.width {
            //I want the scroll view to go to a content offset where I only see the newest added tags.
            //So, I find out how big the TagHolderViewWidth has grown. Then, I see how big the screen is, and the difference is the area that is off the screen, accoiunting for the last two buttons at the end of the screen
            //Therefore, I want to have contentOffset start at the end of the area that has been pushed off screen.
            let screenWidth = self.frame.size.width
            let chosenTagHolderViewWidth = theTagChosenHolderView.frame.size.width
            //I have not totally figured out why we need to add the TrailingConstraint into the equation, but that is what makes the final spacing right, you would think it gets accounted for in the width of the theTagChosenHolderView, but for some reason this makes the scroll view work like its supposed to. 
            theScrollView.setContentOffset(CGPoint(x: chosenTagHolderViewWidth - screenWidth + theFinishedButtonsStackView.frame.width + theTrailingSearchButtonConstraint.constant, y: 0), animated: true)
        }
    }
    
    //Purpose: we need to override this, to tell whenever a hit occured on the view. When it does, we still let the tap pass through to the subview, but, we let the delegate know that somewhere on the view, it was hit.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        scrollViewSearchViewDelegate?.scrollViewSearchViewTapOccurred()
        return super.hitTest(point, with: event)
    }
    
    class func instanceFromNib() -> ScrollViewSearchView {
        // the nibName has to match your class file and your xib file
        return UINib(nibName: "ScrollViewSearchView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ScrollViewSearchView
    }
}


