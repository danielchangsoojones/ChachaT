//
//  UserDetailPopUpViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse

//enums
public enum Fact {
    case FactOne
    case FactTwo
    case FactThree
}


class UserDetailPopUpViewController: PopUpSuperViewController {
    
    var keyboardHeight : CGFloat = 216
    @IBOutlet weak var theDescriptionTextView: UITextView!
    @IBOutlet weak var theSaveButton: UIButton!
    
    var factNumber: Fact = .FactOne
    var factDescriptionText: String?
    
    var delegate: PopUpViewControllerDelegate?
    
    @IBAction func save(sender: AnyObject) {
        theSaveButton.enabled = false
        let currentUser = User.currentUser()
        switch factNumber{
        case .FactOne: currentUser?.factOne = theDescriptionTextView.text
        case .FactTwo: currentUser?.factTwo = theDescriptionTextView.text
        case .FactThree: currentUser?.factThree = theDescriptionTextView.text
        }
        theActivitySpinner.hidden = false
        theActivitySpinner.startAnimating()
        currentUser?.saveInBackgroundWithBlock({ (success, error) in
            if success {
                self.delegate?.passFactDescription(self.theDescriptionTextView.text, fact: self.factNumber)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    @IBAction func clearText(sender: AnyObject) {
        theDescriptionTextView.text = ""
        theDescriptionTextView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About You"
        contentSizeInPopup = CGSizeMake(self.view.bounds.width - 75, self.view.bounds.height - keyboardHeight - 100)
        theDescriptionTextView.text = factDescriptionText
        placeHolderText = "Something interesting about you..."
        if factDescriptionText == placeHolderText {
            //this happens when the string passed to it is the placeholder because the user has not entered a bullet description yet.
            theDescriptionTextView.textColor = placeHolderTextColor
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UserDetailPopUpViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        editingBeginsTextView(textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        editingEndedTextView(textView, placeHolderText: placeHolderText)
    }
}
