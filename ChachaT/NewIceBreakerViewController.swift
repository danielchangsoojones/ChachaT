//
//  NewIceBreakerViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

protocol NewIceBreakerControllerDelegate {
    func passUpdated(iceBreaker: IceBreaker)
}

class NewIceBreakerViewController: UIViewController {
    struct Constant {
        static let maxCharacterCount: Int = 150
    }
    
    var theNewIceBreakerView: NewIceBreakerView!
    var theTextView: UITextView!
    var theCharCountLabel: UILabel!
    
    var iceBreaker: IceBreaker!
    var dataStore: NewIceBreakerDataStore = NewIceBreakerDataStore()
    var delegate: NewIceBreakerControllerDelegate?
    
    init(iceBreaker: IceBreaker) {
        super.init(nibName: nil, bundle: nil)
        self.iceBreaker = iceBreaker
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        textViewSetup()
        navBarSetup()
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
        theNewIceBreakerView.theSaveButton.addTarget(self, action: #selector(saveButtonPressed(sender:)), for: .touchUpInside)
        theCharCountLabel = theNewIceBreakerView.theCharCountLabel
        self.view.addSubview(theNewIceBreakerView)
    }
    
    func saveButtonPressed(sender: UIButton) {
        if theTextView.text != "" {
            iceBreaker.text = theTextView.text
        }
        
        //TODO: technically when they're saving a totally new ice breaker, then we go back to the screen, and if they delete it, then it won't delete because no ParseIceBreaker exists yet
        dataStore.save(iceBreaker: iceBreaker)
        delegate?.passUpdated(iceBreaker: iceBreaker)
        popVC()
    }
}

//nav bar setup
extension NewIceBreakerViewController {
    fileprivate func navBarSetup() {
        theNewIceBreakerView.theInfoIndicator.addTarget(self, action: #selector(infoIndicatorPressed(sender:)), for: .touchUpInside)
        self.navigationItem.titleView = theNewIceBreakerView.theTitleView
    }
    
    func infoIndicatorPressed(sender: UIButton) {
        print("info indi pressed")
    }
}

extension NewIceBreakerViewController: UITextViewDelegate {
    fileprivate func textViewSetup() {
        theTextView = theNewIceBreakerView.theTextView
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        theTextView.delegate = self
        if let initialText = iceBreaker.text {
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
