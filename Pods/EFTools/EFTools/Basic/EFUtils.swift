//
//  EFUtils.swift
//  EFTools
//
//  Created by Brett Keck on 3/7/16.
//  Copyright © 2016 Brett Keck. All rights reserved.
//

import UIKit
import SCLAlertView

public class EFUtils {
    public class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Za-z0-9-_.]+[@]{1}[A-Za-z0-9-]+[.]*[A-Za-z0-9-]+[.]{1}[A-Za-z]+"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    public class func isValidPassword(password: String, minLength: Int = 6, uppercase: Bool = true, lowercase: Bool = true, number: Bool = true, specialCharacter: Bool = true) -> Bool {
        return password.characters.count >= minLength &&
            (!number || password.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil) &&
            (!uppercase || password.rangeOfCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet()) != nil) &&
            (!lowercase || password.rangeOfCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet()) != nil) &&
            (!specialCharacter || password.rangeOfCharacterFromSet(NSCharacterSet.symbolCharacterSet()) != nil)
    }
    
    public class func showError(title title: String = "Error", message: String = "An error occurred with your request.", closeButton: String = "Dismiss", useBasic: Bool = true) {
        if useBasic {
            showBasicError(title, message: message, closeButton: closeButton)
        } else {
            showSCLError(title, message: message, closeButton: closeButton)
        }
    }
    
    class func showBasicError(title: String, message: String, closeButton: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: closeButton, style: .Default, handler: nil))
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            rootVC.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    class func showSCLError(title: String, message: String, closeButton: String) {
        let alert = SCLAlertView()
        alert.showError(title, subTitle: message, closeButtonTitle: closeButton, duration: 0, colorStyle: 0xC1272D, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
    
    public class func showTextFieldAlert(title title: String, message: String, defaultButton: String = "Continue", cancelButton: String = "Cancel", useBasic: Bool = true, completion: (String) -> Void) {
        if useBasic {
            showBasicTextFieldAlert(title, message: message, defaultButton: defaultButton, cancelButton: cancelButton, completion: completion)
        } else {
            showSCLTextFieldAlert(title, message: message, defaultButton: defaultButton, cancelButton: cancelButton, completion: completion)
        }
    }
    
    class func showBasicTextFieldAlert(title: String, message: String, defaultButton: String, cancelButton: String, completion: (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: defaultButton, style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0]
            completion(textField.text ?? "")
        }))
        alert.addAction(UIAlertAction(title: cancelButton, style: .Cancel, handler: nil))
        alert.addTextFieldWithConfigurationHandler(nil)
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            rootVC.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    class func showSCLTextFieldAlert(title: String, message: String, defaultButton: String, cancelButton: String, completion: (String) -> Void) {
        let alert = SCLAlertView()
        let textfield = alert.addTextField()
        alert.addButton(defaultButton) { () -> Void in
            completion(textfield.text ?? "")
        }
        alert.showNotice(title, subTitle: message, closeButtonTitle: cancelButton, duration: 0, colorStyle: 0xC1272D, colorTextButton: 0xFFFFFF, circleIconImage: nil)
    }
}