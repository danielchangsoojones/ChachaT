//
//  NewIceBreakerViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class NewIceBreakerViewController: UIViewController {
    struct Constant {
        static let maxCharacterCount: Int = 150
    }
    
    var theNewIceBreakerView: NewIceBreakerView!
    var theTextView: UITextView!
    var theCharCountLabel: UILabel!
    
    var initialText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        textViewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        theTextView.becomeFirstResponder()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func viewSetup() {
        theNewIceBreakerView = NewIceBreakerView(frame: self.view.bounds)
        theTextView = theNewIceBreakerView.theTextView
        theNewIceBreakerView.theSaveButton.addTarget(self, action: #selector(saveButtonPressed(sender:)), for: .touchUpInside)
        theCharCountLabel = theNewIceBreakerView.theCharCountLabel
        self.view.addSubview(theNewIceBreakerView)
    }
    
    func saveButtonPressed(sender: UIButton) {
        
    }
}

extension NewIceBreakerViewController: UITextViewDelegate {
    fileprivate func textViewSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        theTextView.delegate = self
        if let initialText = initialText {
            theTextView.text = initialText
        }
        theNewIceBreakerView.setTextView(placeholder: "i.e. what is your favorite color?")
        theCharCountLabel.text = Constant.maxCharacterCount.toString
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            theTextView.contentInset.bottom = keyboardSize.height
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        return newLength < Constant.maxCharacterCount
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.characters.count
        let charactersLeft = Constant.maxCharacterCount - characterCount
        theCharCountLabel.text = "\(charactersLeft)"
    }
    
}
