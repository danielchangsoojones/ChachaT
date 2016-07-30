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
//        translucent = true //making the background of search box translucent
//        searchBarStyle = .Minimal
        tintColor = UIColor.whiteColor() //makes the cancel button of search bar and keyboard cursor a certain color
        searchBarStyle = .Minimal
        translucent = true //makes the background of searh box translucent, if I get rid of this, it turns black
        
        setSearchIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSearchIcon() {
        let image: UIImage = UIImage(named: "SearchIconWhite")!
        setImage(image, forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
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
    
    override func drawRect(rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search field
            let searchField: UITextField = (subviews[0]).subviews[index] as! UITextField
            
            searchField.layer.cornerRadius = preferredBorderRadius
            searchField.layer.borderColor = preferredBorderColor
            searchField.layer.borderWidth = preferredBorderWidth
        
        }
        
        super.drawRect(rect)
    }

}
