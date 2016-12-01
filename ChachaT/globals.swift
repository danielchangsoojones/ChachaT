//
//  File.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/12/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import EFTools

//colors
struct CustomColors {
    static let JellyTeal = UIColor.rgba(1, green: 195, blue: 167, alpha: 1)
    static let BombayGrey = UIColor.rgba(212, green: 213, blue: 215, alpha: 1)
    static let PeriwinkleGray = UIColor.rgba(246, green: 248, blue: 251, alpha: 1)
    static let SilverChaliceGrey = UIColor.rgba(178, green: 178, blue: 178)
    static let TutorialOverlayColor = UIColor.black.withAlphaComponent(0.7)
}

let ChachaTeal = UIColor.rgba(1, green: 195, blue: 167, alpha: 1)
let facebookBlue = UIColor.rgba(45, green: 68, blue: 133, alpha: 1)
let ChachaBombayGrey = UIColor.rgba(212, green: 213, blue: 215, alpha: 1)
let placeHolderTextColor = UIColor.rgba(212, green: 213, blue: 215, alpha: 0.5)
let PeriwinkleGray = UIColor.rgba(246, green: 248, blue: 251, alpha: 1)
let FilteringPageStackViewLinesColor = UIColor.rgba(246, green: 248, blue: 251, alpha: 0.75)
let BackgroundPageColor = UIColor.rgba(189, green: 239, blue: 232)

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
    static let SearchIcon = "SearchIcon"
    static let ChachaTealLogo = "Chacha-Teal-Logo"
    static let dropDownUpArrow = "DropDownUpArrow"
}

struct ImportantDimensions {
    static let BarButtonItemSize : CGSize = CGSize(width: 22, height: 22) //as per the Apple Human Interface Guidelines
    static let BarButtonInset : CGFloat = 22
    static let StatusBarHeight = UIApplication.shared.statusBarFrame.size.height
}

//storyboard identifiers
public enum StoryboardIdentifiers : String {
   case BottomPicturePopUpViewController
   case QuestionOnboardingCell
   case SuperTagViewController
   case DistanceSingleRangeSlider
}

//helper functions
func isIphone3by2AR() -> Bool {
    let screenSize: CGRect = UIScreen.main.bounds
    let screenWidth = screenSize.width
    let screenHeight = screenSize.height
    if screenHeight / screenWidth == 1.5 {
        return true
    }
    return false
}

func setBottomBlur(blurHeight: CGFloat, color: UIColor) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - blurHeight, width:  UIScreen.main.bounds.width, height: blurHeight)
    let transparent = UIColor(white: 1, alpha: 0).cgColor
    let opaque = color.withAlphaComponent(0.5).cgColor
    gradientLayer.colors = [transparent, opaque]
    gradientLayer.locations = [0.0, 1.0]
    
    return gradientLayer
}

//Text View methods
func editingBeginsTextView(_ textView: UITextView) {
    if textView.textColor == placeHolderTextColor {
        textView.text = nil
        textView.textColor = ChachaBombayGrey
    }
}

func editingEndedTextView(_ textView: UITextView, placeHolderText: String) {
    if textView.text.isEmpty {
        textView.text = placeHolderText
        textView.textColor = placeHolderTextColor
    }
}

func resetTextView(_ textView: UITextView, placeHolderText: String) {
    textView.text = placeHolderText
    textView.textColor = placeHolderTextColor
}
