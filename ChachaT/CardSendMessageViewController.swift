//
//  CardSendMessageViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/14/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SCLAlertView

struct CardMesageConstants {
    static let salutationTextColor: UIColor = CustomColors.SilverChaliceGrey
    static let maxCharacterCount: Int = 150
    static let textViewPlaceholderColor: UIColor = CustomColors.SilverChaliceGrey
    static let textViewTextColor: UIColor = UIColor.black
    static let textViewPlaceholderText: String = "Write a beautiful message..."
}

class CardSendMessageViewController: UIViewController {
    
    class func presentFrom(_ vc: UIViewController, userToSend: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cardSendMessageVC = storyboard.instantiateViewController(withIdentifier: "CardSendMessageViewController") as! CardSendMessageViewController
        cardSendMessageVC.userToSend = userToSend
        vc.presentVC(cardSendMessageVC)
    }
    
    @IBOutlet weak var theSalutationView: MessageSalutationView!
    @IBOutlet weak var theCharCountLabel: UILabel!
    @IBOutlet weak var theSendButton: UIButton!
    @IBOutlet weak var theKeyboardBarView: UIView!
    @IBOutlet weak var theTextView: UITextView!
    
    //constraints
    @IBOutlet weak var theBottomKeyboardViewConstraint: NSLayoutConstraint!
    
    var userToSend: User?
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        let dataStore = CardSendMessageDataStore()
        if let otherUser = self.userToSend {
            dataStore.sendCardMessage(text: self.theTextView.text, otherUser: otherUser)
        }
        dismiss(animated: true, completion: {
            SCLAlertView().showSuccess("Message Successfully Sent", subTitle: "The message has successfully been sent")
        })
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        setSalutationView()
        setKeyboardBarView()
        textViewSetup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setSalutationView() {
        if let user = userToSend {
            theSalutationView.setSalutationView(name: user.firstName ?? "", profileImage: user.profileImage, beginsWithTo: true)
        }
    }
    
    func setKeyboardBarView() {
        theCharCountLabel.text = CardMesageConstants.maxCharacterCount.toString
        theCharCountLabel.textColor = CardMesageConstants.salutationTextColor
        theSendButton.setCornerRadius(radius: 10)
        topLineSetup()
    }
    
    func topLineSetup() {
        let line = UIView()
        line.backgroundColor = CustomColors.SilverChaliceGrey
        line.alpha = 0.5
        theKeyboardBarView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.trailing.top.leading.equalTo(theKeyboardBarView)
            make.height.equalTo(0.5)
        }
    }

}

//keyboard extension
extension CardSendMessageViewController {
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            theBottomKeyboardViewConstraint.constant = keyboardHeight
        }
    }
}

//textview extension
//TODO: I could use RSKPlaceholderText view to literally get rid of all this placeholder code
extension CardSendMessageViewController: UITextViewDelegate {
    func textViewSetup() {
        theTextView.delegate = self
        theTextView.becomeFirstResponder()
        applyPlaceholderStyle(theTextView, placeholderText: CardMesageConstants.textViewPlaceholderText)
    }
    
    func applyPlaceholderStyle(_ aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = CardMesageConstants.textViewPlaceholderColor
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(_ aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = CardMesageConstants.textViewTextColor
        aTextview.alpha = 1.0
    }
    
    func textViewShouldBeginEditing(_ aTextView: UITextView) -> Bool
    {
        if aTextView == theTextView && aTextView.text == CardMesageConstants.textViewPlaceholderText
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
            if newLength > CardMesageConstants.maxCharacterCount {
                //the textview has hit its maximum character count
                return false
            }
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == theTextView && textView.text == CardMesageConstants.textViewPlaceholderText
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
            applyPlaceholderStyle(textView, placeholderText: CardMesageConstants.textViewPlaceholderText)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.characters.count
        let charactersLeft = CardMesageConstants.maxCharacterCount - characterCount
        theCharCountLabel.text = "\(charactersLeft)"
    }
}
