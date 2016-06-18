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
let BlurryFilteringPageBackground = UIColor.rgba(red: 178, green: 178, blue: 178, alpha: 0.25)
let HandBackgroundColorOverlay = UIColor.rgba(red: 0, green: 0, blue: 0, alpha: 0.65)

//storyboard identifiers
public enum StoryboardIdentifiers : String {
   case BottomPicturePopUpViewController
   case QuestionOnboardingCell
}

var anonymousFlowGlobal : AnonymousFlow = .MainPageFirstVisitMatchingPhase
public enum AnonymousFlow {
    case MainPageFirstVisitMatchingPhase
    case MainPageSecondVisitFilteringStage
    case MainPageThirdVisitSignUpPhase
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

func createQuestionBubbleGUI(questionButton: ResizableButton) {
    questionButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
    questionButton.titleLabel?.textAlignment = NSTextAlignment.Center
    questionButton.titleLabel?.numberOfLines = 0
    questionButton.titleEdgeInsets = UIEdgeInsets(top: -5, left: 15, bottom: 0, right: 15)
}

func createBackgroundOverlay() -> UIView {
    let overlayBackgroundColorView: UIView = {
        $0.backgroundColor = HandBackgroundColorOverlay
        $0.userInteractionEnabled = false
        $0.alpha = 0
        return $0
    }(UIView())
    return overlayBackgroundColorView
}

func createHandImageOverlay() -> UIImageView {
    let theHandImage: UIImageView = {
        $0.image = UIImage(named: "Hand")?.imageRotatedByDegrees(-25, flip: false)
        $0.contentMode = .ScaleAspectFit
        $0.alpha = 0
        return $0
    }(UIImageView())
    return theHandImage
}

func createLabelForOverlay(labelString: String) -> UILabel {
    let overlayLabel: UILabel = {
        $0.text = labelString
        $0.alpha = 0
        $0.textColor = UIColor.whiteColor()
        return $0
    }(UILabel())
    return overlayLabel
}

func animateOverlay(backgroundOverlayView: UIView) {
    UIView.animateWithDuration(2, animations: {
        for subview in backgroundOverlayView.subviews {
            subview.alpha = 1
        }
        backgroundOverlayView.alpha = 1
    })
}

//returns true if the user is anonymous and if they are at the anonymous flow that was passed as a parameter
func anonymousFlowStage(anonymousFlow: AnonymousFlow) -> Bool {
    //checking that they are anonymous user, if not, then they don't do the anonymous flow at all.
    if PFAnonymousUtils.isLinkedWithUser(User.currentUser()) {
        //checking to see if the anonymousFlow is at the phase passed by the parameter.
        return anonymousFlowGlobal == anonymousFlow
    }
        return false
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