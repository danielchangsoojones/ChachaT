//
//  NewIceBreakerViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class NewIceBreakerViewController: UIViewController {
    var theTextView: UITextView!

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
        let theView = NewIceBreakerView(frame: self.view.bounds)
        theTextView = theView.theTextView
        theView.theSaveButton.addTarget(self, action: #selector(saveButtonPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(theView)
    }
    
    func saveButtonPressed(sender: UIButton) {
        
    }

}

extension NewIceBreakerViewController: UITextViewDelegate {
    fileprivate func textViewSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        theTextView.delegate = self
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            theTextView.contentInset.bottom = keyboardSize.height
        }
    }
    
    
}
