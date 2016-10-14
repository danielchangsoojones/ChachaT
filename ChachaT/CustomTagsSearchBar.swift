//
//  CustomTagsSearchBar.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class CustomTagsSearchBar: UISearchBar {
    fileprivate struct SearchBarConstants {
        static let borderColor: UIColor = TagViewProperties.borderColor
        static let borderWidth: CGFloat = TagViewProperties.borderWidth
        static let borderRadius: CGFloat = TagViewProperties.cornerRadius
    }
    
    init(placeHolderText: String) {
        super.init(frame: CGRect.zero) //will get set via snapkit constraints
        placeholder = placeHolderText
        tintColor = SearchBarConstants.borderColor //makes the cancel button of search bar and keyboard cursor a certain color
        showsCancelButton = true
        self.autocapitalizationType = .none
        setSearchIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSearchIcon() {
        let image: UIImage = UIImage(named: "SearchIconWhite")!
        setImage(image, for: UISearchBarIcon.search, state: UIControlState())
    }
    
    override func draw(_ rect: CGRect) {
        let searchBarView = subviews[0]
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search field
            let searchField: UITextField = (searchBarView).subviews[index] as! UITextField
            
            searchField.layer.cornerRadius = SearchBarConstants.borderRadius
            searchField.layer.borderColor = SearchBarConstants.borderColor.cgColor
            searchField.layer.borderWidth = SearchBarConstants.borderWidth
            var bounds : CGRect = searchField.frame //saving frame, so we can set bounds after setting height
            bounds.size.height = TagView.getTagViewHeight(TagViewProperties.paddingY) //height of tagViews should = height of search text field
            searchField.bounds = bounds
            searchField.backgroundColor = UIColor.clear
            
            if let magnifyglassIconView = searchField.leftView as? UIImageView {
                magnifyglassIconView.image = magnifyglassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                magnifyglassIconView.tintColor = SearchBarConstants.borderColor
            }
        }
        
        //Hacky way to do this. Getting the subview and finding the backgroundview and then setting the alpha to invisible
        //For some reason, I can't figure out how to get totally transparent without this hack
        //if apple ever changed the UISearchBar, then this code could break.
        if let index = indexOfBackgroundViewInSubviews() {
            let searchBarBackgroundView = searchBarView.subviews[index]
            searchBarBackgroundView.alpha = 0
        }
        
        if let index = indexOfCancelButtonInSubviews() {
            let cancelButton = searchBarView.subviews[index] as! UIButton
            enableCancelButton(cancelButton)
        }
        
        super.draw(rect)
    }
    
    //Purpose: returns the index for the textFieldView of the searchBar
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UITextField.self) {
                index = i
                break
            }
        }
        
        return index
    }
    
    //Purpose: returns the index for the textFieldView of the searchBar
    func indexOfBackgroundViewInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UIView.self) {
                //this should find the background view, but if apple changes UISearchBar class, then this code could break
                index = i
                break
            }
        }
        return index
    }
    
    //Purpose: returns the index for the cancel button of the searchBar.
    //For some reason, I can not get the cancel button to be white the initial time it is shown. Not sure why, but it only turns white after the search bar has been tapped
    func indexOfCancelButtonInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UIButton.self) {
                //this should find the cancel button, but if apple changes UISearchBar class, then this code could break
                index = i
                break
            }
        }
        return index
    }
    
    //This is a hacky way to do things. But, by defualt, a UISearchBar only lets the cancelButton be clickable when the firstResponder is active. But, we want the cancel button to be a way for the user to exit the page. So, when the user was coming to the search page at first, and if they tried to click cancel, it wasn't responding. The user had to hit the searchBar TextField, which would bring up the first responder, and then they could hit cancel. This function fixes things and lets the cancel button be pushed the first time.
    func enableCancelButton(_ cancelButton: UIButton) {
        cancelButton.setTitleColor(SearchBarConstants.borderColor, for: UIControlState())
        cancelButton.isEnabled = true
        cancelButton.isUserInteractionEnabled = true
    }
    
}
