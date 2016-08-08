//
//  File.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import EFTools
import Parse

//colors
let ChachaTeal = UIColor.rgba(red: 1, green: 195, blue: 167, alpha: 1)
let facebookBlue = UIColor.rgba(red: 45, green: 68, blue: 133, alpha: 1)
let ChachaBombayGrey = UIColor.rgba(red: 212, green: 213, blue: 215, alpha: 1)
let placeHolderTextColor = UIColor.rgba(red: 212, green: 213, blue: 215, alpha: 0.5)
let PeriwinkleGray = UIColor.rgba(red: 246, green: 248, blue: 251, alpha: 1)
let FilteringPageStackViewLinesColor = UIColor.rgba(red: 246, green: 248, blue: 251, alpha: 0.75)
let BackgroundPageColor = UIColor.rgba(red: 189, green: 239, blue: 232)

//Match Constants
struct Constants {
    static let createdAt = "createdAt"
    static let chatRoom = "chatRoom"
    static let sender = "sender"
    static let currentUser = "currentUser"
    static let targetUser = "targetUser"
    static let mutualMatch = "mutualMatch"
    static let male = "male"
    static let female = "female"
    static let dateMatch = "DateMatch"
    static let dateChat = "DateChat"
    static let id = "id"
    static let firstName = "first_name"
    static let lastName = "last_name"
    static let name = "name"
    static let profileImage = "profileImage.jpg"
    static let objectId = "objectId"
    static let gender = "gender"
    static let discoverable = "discoverable"
    static let isMatch = "isMatch"
    static let email = "email"
}

struct ImageNames {
    static let DownArrow = "DownArrow"
}

//storyboard identifiers
public enum StoryboardIdentifiers : String {
   case BottomPicturePopUpViewController
   case QuestionOnboardingCell
   case FilterTagViewController
   case DistanceSingleRangeSlider
}

//helper functions
func isIphone3by2AR() -> Bool {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let screenWidth = screenSize.width
    let screenHeight = screenSize.height
    if screenHeight / screenWidth == 1.5 {
        return true
    }
    return false
}

func setBottomBlur() -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - 100, width:  UIScreen.mainScreen().bounds.width, height: 100)
    let transparent = UIColor(white: 1, alpha: 0).CGColor
    let opaque = UIColor.rgba(red: 1, green: 195, blue: 167, alpha: 0.5).CGColor
    gradientLayer.colors = [transparent, opaque]
    gradientLayer.locations = [0.0, 0.8]
    
    return gradientLayer
}

func showSearchBox(searchBoxHolder: UIView) -> CustomTagsSearchBar {
    let searchBox = CustomTagsSearchBar(borderColor: UIColor.whiteColor().CGColor, borderWidth: 2.0, borderRadius: 10.0, placeHolderText: "Search Tags")
    searchBoxHolder.addSubview(searchBox)
    searchBox.snp_makeConstraints { (make) in
        make.edges.equalTo(searchBoxHolder)
    }
    return searchBox
}

//Text View methods
func editingBeginsTextView(textView: UITextView) {
    if textView.textColor == placeHolderTextColor {
        textView.text = nil
        textView.textColor = ChachaBombayGrey
    }
}

func editingEndedTextView(textView: UITextView, placeHolderText: String) {
    if textView.text.isEmpty {
        textView.text = placeHolderText
        textView.textColor = placeHolderTextColor
    }
}

func resetTextView(textView: UITextView, placeHolderText: String) {
    textView.text = placeHolderText
    textView.textColor = placeHolderTextColor
}