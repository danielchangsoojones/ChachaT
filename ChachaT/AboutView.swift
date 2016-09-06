//
//  AboutView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/4/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import MBAutoGrowingTextView

protocol AboutViewDelegate {
    func textHasChanged(bulletPointNumber: Int)
}

class AboutView: UIView {
    private struct AboutViewConstants {
        static let textViewPlaceholder = "Something about you..."
        static let maxCharacterCount : Int = 500
    }
    
    
    // Our custom view from the XIB file. We basically have to have our view on top of a normal view, since it is a nib file.
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theCharacterCount: UILabel!
    @IBOutlet weak var theAutoGrowingTextView: MBAutoGrowingTextView!
    
    var theBulletPointNumber : Int!
    var delegate : AboutViewDelegate?
    
    //Called when the view is created via storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        GUISetup()
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type PhotoEditingView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    func xibSetup() {
        NSBundle.mainBundle().loadNibNamed("AboutView", owner: self, options: nil)[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    func GUISetup() {
        initialCharacterCountSetup()
        textViewSetup()
    }
    
    func initialCharacterCountSetup() {
        theCharacterCount.text = "\(AboutViewConstants.maxCharacterCount)"
    }
    
    func setImportantInformation(delegate: AboutViewDelegate, bulletPointNumber: Int) {
        self.delegate = delegate
        self.theBulletPointNumber = bulletPointNumber
        let prefixString = "Bullet Point #"
        theTitleLabel.text = prefixString + "\(bulletPointNumber)"
    }
}

//needed to manually create placeholder for a textview
extension AboutView: UITextViewDelegate {
    func textViewSetup() {
        theAutoGrowingTextView.delegate = self
        applyPlaceholderStyle(theAutoGrowingTextView, placeholderText: AboutViewConstants.textViewPlaceholder)
    }
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGrayColor()
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkTextColor()
        aTextview.alpha = 1.0
    }
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
        if aTextView == theAutoGrowingTextView && aTextView.text == AboutViewConstants.textViewPlaceholder
        {
            // move cursor to start
            moveCursorToStart(aTextView)
        }
        return true
    }
    
    func moveCursorToStart(aTextView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            if newLength > AboutViewConstants.maxCharacterCount {
                //the textview has hit its maximum character count
                return false
            }
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == theAutoGrowingTextView && textView.text == AboutViewConstants.textViewPlaceholder
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: AboutViewConstants.textViewPlaceholder)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let characterCount = textView.text.characters.count
        let charactersLeft = AboutViewConstants.maxCharacterCount - characterCount
        theCharacterCount.text = "\(charactersLeft)"
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        delegate?.textHasChanged(theBulletPointNumber)
    }
    
    func getCurrentText() -> String {
        return theAutoGrowingTextView.text
    }
}
