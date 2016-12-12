//
//  NewIceBreakerView.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

class NewIceBreakerView: UIView {
    var theTextView: UITextView = UITextView()
    var theKeyboardBar: UIView = UIView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        textViewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func keyboardBarSetup() {
        
    }
    
    fileprivate func textViewSetup() {
        let customView = UIView(frame: CGRect(x: 0,y: 0,w: 10,h: 100))
        customView.backgroundColor = UIColor.red
        theTextView.inputAccessoryView = customView
        self.addSubview(theTextView)
        theTextView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension NewIceBreakerView {
//    func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            let keyboardHeight = keyboardSize.height
//            theBottomKeyboardViewConstraint.constant = keyboardHeight
//        }
//    }
}
