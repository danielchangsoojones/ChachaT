//
//  AboutView.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/4/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import MBAutoGrowingTextView

class AboutView: UIView {
    fileprivate struct AboutViewConstants {
        static let maxCharacterCount : Int = 500
        static let maxTextFieldCharacterCount : Int = 30
    }
    
    enum AboutViewType {
        case growingTextView
        case normalTextField
        case tappableCell
        case segueCell
    }
    
    // Our custom view from the XIB file. We basically have to have our view on top of a normal view, since it is a nib file.
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theCharacterCount: UILabel!
    @IBOutlet weak var theInputContentView: UIView!
    //TODO: figure out how to make this not in xib file, but in the code. I couldn't figure out how to set the constraints in code, and MBAutoGrowingTextView requires special autolayout constraints if you look at docs.
    @IBOutlet weak var theAutoGrowingTextView: MBAutoGrowingTextView!
    var theTextField: UITextField?
    var theInnerLabel: UILabel?
    
    var theBulletPointNumber : Int?
    var thePlaceholderText : String = ""
    var wasEdited : Bool = false
    var theType : AboutViewType = .growingTextView
    
    init(title: String, placeHolder: String, type: AboutViewType) {
        super.init(frame: CGRect.zero)
        xibSetup()
        self.thePlaceholderText = placeHolder
        self.theTitleLabel.text = title
        self.theType = type
        GUISetup(type)
    }
    
    //for initializing the autogrowingtextField (bullet points)
    convenience init(title: String, placeHolder: String, bulletPointNumber: Int, type: AboutViewType) {
        self.init(title: title, placeHolder: placeHolder, type: type)
        theBulletPointNumber = bulletPointNumber
    }
    
    //for intializing the tappable cells
    convenience init(title: String, placeHolder: String, innerText: String?, action: @escaping (_ sender: AboutView) -> (), type: AboutViewType) {
        self.init(title: title, placeHolder: placeHolder, type: type)
        tappableCellSetup(innerText, action: action)
        if type == .segueCell {
            segueIndicatorSetup()
        }
    }
    
    //use this to initialize from storyboard, but we haven't needed to do that
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //In storyboard we make sure the File Owner, NOT THE VIEW CLASS TYPE, is set to type PhotoEditingView. If that is not happening, then it creates a recursion loop that crashes the application. Talk to Daniel Jones if this doesn't make sense.
    func xibSetup() {
        Bundle.main.loadNibNamed("AboutView", owner: self, options: nil)?[0] as! UIView
        //basically just setting the customView I built on top of a normal view. It's weird, but that's how you load a xib via storyboard
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    func GUISetup(_ type: AboutViewType) {
        hideBulletPointComponents(true) //want the autoGrowingTextView to not be shown, unless it is supposed to be
        switch type {
        case .growingTextView:
            initialCharacterCountSetup()
            autoGrowingTextViewSetup()
            hideBulletPointComponents(false) //it is supposed to be shown
        case .normalTextField:
            textFieldSetup()
        default:
            break
        }
    }
    
    func hideBulletPointComponents(_ hide: Bool) {
        theAutoGrowingTextView.isHidden = hide
        theCharacterCount.isHidden = hide
    }
    
    func initialCharacterCountSetup() {
        theCharacterCount.text = "\(AboutViewConstants.maxCharacterCount)"
    }
    
    func getType() -> AboutViewType {
        return theType
    }
    
    func getCurrentText() -> String? {
        if theAutoGrowingTextView.isHidden {
            if let textField = theTextField , textField.text != nil {
                return textField.text!
            }
        } else {
            return theAutoGrowingTextView.text
        }
        return nil //shouldn't reach here unless they edited the textView to have no text
    }
    
    //Purpose: sees which textfield, textview, or label to change, based upon which ones are not nil/hidden
    func setCurrentText(_ text: String) {
        if theAutoGrowingTextView.isHidden {
            if let textField = theTextField {
                textField.text = text
            } else if theInnerLabel != nil {
                setInnerTitle(text)
            }
        } else {
            theAutoGrowingTextView.text = text
            applyNonPlaceholderStyle(theAutoGrowingTextView)
        }
    }
    
    func getTitle() -> String {
        return theTitleLabel.text ?? ""
    }
}

//extension for the autogrowingTextView
extension AboutView: UITextViewDelegate {
    func autoGrowingTextViewSetup() {
        theAutoGrowingTextView.delegate = self
        applyPlaceholderStyle(theAutoGrowingTextView, placeholderText: thePlaceholderText)
    }
    
    func getBulletPointNumber() -> Int? {
        if let theBulletPointNumber = theBulletPointNumber {
            return theBulletPointNumber
        }
        return nil
    }
    
    func applyPlaceholderStyle(_ aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGray
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(_ aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkText
        aTextview.alpha = 1.0
    }
    
    func textViewShouldBeginEditing(_ aTextView: UITextView) -> Bool
    {
        if aTextView == theAutoGrowingTextView && aTextView.text == thePlaceholderText
        {
            // move cursor to start
            moveCursorToStart(aTextView)
        }
        return true
    }
    
    func moveCursorToStart(_ aTextView: UITextView)
    {
        DispatchQueue.main.async(execute: {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
            if textView == theAutoGrowingTextView && textView.text == thePlaceholderText
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
            applyPlaceholderStyle(textView, placeholderText: thePlaceholderText)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.characters.count
        let charactersLeft = AboutViewConstants.maxCharacterCount - characterCount
        theCharacterCount.text = "\(charactersLeft)"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        wasEdited = true
    }
}

//extension for the normal textField
extension AboutView : UITextFieldDelegate {
    func textFieldSetup() {
        theTextField = UITextField()
        theTextField!.delegate = self
        theTextField!.placeholder = thePlaceholderText
        theInputContentView.addSubview(theTextField!)
        theTextField!.snp_makeConstraints { (make) in
            make.edges.equalTo(theInputContentView)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        wasEdited = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= AboutViewConstants.maxTextFieldCharacterCount
    }
}

//tappable/segue cell extension
extension AboutView {
    func tappableCellSetup(_ innerText: String?, action: @escaping (_ sender: AboutView) -> ()) {
        theInnerLabel = UILabel()
        theInnerLabel!.text = innerText ?? thePlaceholderText
        theInputContentView.addSubview(theInnerLabel!)
        theInnerLabel!.snp_makeConstraints(closure: { (make) in
            //TODO: make these constants mean something. They should be aligned with the textview placeholders/start
            make.leading.equalTo(theInputContentView).offset(10)
            make.centerY.equalTo(theInputContentView)
        })
        theInputContentView.addTapGesture { (tapped) in
            action(sender: self)
        }
    }
    
    func segueIndicatorSetup() {
        let image = UIImage(named: "DropDownUpArrow")
        let rotatedImage = image?.imageRotatedByDegrees(90, flip: false)
        let imageView = UIImageView(image: rotatedImage)
        theInputContentView.addSubview(imageView)
        imageView.snp_makeConstraints(closure: { (make) in
            //TODO: make these constants mean something. They should be aligned with the textview placeholders/start
            make.trailing.equalTo(theInputContentView).inset(10)
            make.centerY.equalTo(theInputContentView)
        })
    }
    
    func setInnerTitle(_ text: String) {
        theInnerLabel?.text = text
    }
}

