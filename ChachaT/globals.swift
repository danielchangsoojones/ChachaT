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
let ChachaTeal = UIColor.rgba(red: 1, green: 195, blue: 167, alpha: 1)
let facebookBlue = UIColor.rgba(red: 45, green: 68, blue: 133, alpha: 1)
let ChachaBombayGrey = UIColor.rgba(red: 212, green: 213, blue: 215, alpha: 1)
let placeHolderTextColor = UIColor.rgba(red: 212, green: 213, blue: 215, alpha: 0.5)
let PeriwinkleGray = UIColor.rgba(red: 246, green: 248, blue: 251, alpha: 1)

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