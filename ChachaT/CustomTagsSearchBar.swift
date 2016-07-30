//
//  CustomTagsSearchBar.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class CustomTagsSearchBar: UISearchBar {
    var preferredBorderColor: CGColor!
    var preferredBorderWidth: CGFloat!
    var preferredBorderRadius: CGFloat!
    
    init(borderColor: CGColor, borderWidth: CGFloat, borderRadius: CGFloat, placeHolderText: String) {
        super.init(frame: CGRectZero) //will get set via snapkit constraints
        
        self.frame = frame
        placeholder = placeHolderText
        preferredBorderColor = borderColor
        preferredBorderWidth = borderWidth
        preferredBorderRadius = borderRadius
        tintColor = UIColor.whiteColor() //makes the cancel button of search bar and keyboard cursor a certain color
        
        setSearchIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSearchIcon() {
        let image: UIImage = UIImage(named: "SearchIconWhite")!
        setImage(image, forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
    }
    
    override func drawRect(rect: CGRect) {
        let searchBarView = subviews[0]
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search field
            let searchField: UITextField = (searchBarView).subviews[index] as! UITextField
            
            searchField.layer.cornerRadius = preferredBorderRadius
            searchField.layer.borderColor = preferredBorderColor
            searchField.layer.borderWidth = preferredBorderWidth
            searchField.backgroundColor = UIColor.clearColor()
        
        }
        
        //Hacky way to do this. Getting the subview and finding the backgroundview and then setting the alpha to invisible
        //For some reason, I can't figure out how to get totally transparent without this hack
        //if apple ever changed the UISearchBar, then this code could break.
        if let index = indexOfBackgroundViewInSubviews() {
            let searchBarBackgroundView = searchBarView.subviews[index]
            searchBarBackgroundView.alpha = 0
        }
        
        super.drawRect(rect)
    }
    
    //Purpose: returns the index for the textFieldView of the searchBar
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKindOfClass(UITextField) {
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
            if searchBarView.subviews[i].isKindOfClass(UIView) {
                //this should find the background view, but if apple changes UISearchBar class, then this code could break
                index = i
                break
            }
        }
        return index
    }

}
