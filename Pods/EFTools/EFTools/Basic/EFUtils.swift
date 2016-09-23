//
//  EFUtils.swift
//  EFTools
//
//  Created by Brett Keck on 3/7/16.
//  Copyright © 2016 Brett Keck. All rights reserved.
//

import UIKit

open class EFUtils {
    open class func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    open class func isValidPassword(_ password: String, minLength: Int = 6, uppercase: Bool = true, lowercase: Bool = true, number: Bool = true, specialCharacter: Bool = true) -> Bool {
        return password.characters.count >= minLength &&
            (!number || password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil) &&
            (!uppercase || password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil) &&
            (!lowercase || password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil) &&
            (!specialCharacter || password.rangeOfCharacter(from: CharacterSet.symbols) != nil)
    }
    
    open class func showError(_ title: String = "Error", message: String = "An error occurred with your request.", closeButton: String = "Dismiss", useBasic: Bool = true) {
//        if useBasic {
            showBasicError(title, message: message, closeButton: closeButton)
//        } else {
//            showSCLError(title, message: message, closeButton: closeButton)
//        }
    }
    
    class func showBasicError(_ title: String, message: String, closeButton: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: closeButton, style: .default, handler: nil))
        presentBasicAlert(alert)
    }
    
//    class func showSCLError(_ title: String, message: String, closeButton: String) {
//        let alert = SCLAlertView()
//        alert.showError(title, subTitle: message, closeButtonTitle: closeButton, duration: 0, colorStyle: 0xC1272D, colorTextButton: 0xFFFFFF, circleIconImage: nil)
//    }
    
    open class func showTextFieldAlert(_ title: String, message: String, defaultButton: String = "Continue", cancelButton: String = "Cancel", useBasic: Bool = true, completion: @escaping (String) -> Void) {
//        if useBasic {
            showBasicTextFieldAlert(title, message: message, defaultButton: defaultButton, cancelButton: cancelButton, completion: completion)
//        } else {
//            showSCLTextFieldAlert(title, message: message, defaultButton: defaultButton, cancelButton: cancelButton, completion: completion)
//        }
    }
    
    class func showBasicTextFieldAlert(_ title: String, message: String, defaultButton: String, cancelButton: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: defaultButton, style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0]
            completion(textField.text ?? "")
        }))
        alert.addAction(UIAlertAction(title: cancelButton, style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: nil)
        presentBasicAlert(alert)
    }
    
//    class func showSCLTextFieldAlert(_ title: String, message: String, defaultButton: String, cancelButton: String, completion: @escaping (String) -> Void) {
//        let alert = SCLAlertView()
//        let textfield = alert.addTextField()
//        alert.addButton(defaultButton) { () -> Void in
//            completion(textfield.text ?? "")
//        }
//        alert.showNotice(title, subTitle: message, closeButtonTitle: cancelButton, duration: 0, colorStyle: 0xC1272D, colorTextButton: 0xFFFFFF, circleIconImage: nil)
//    }
    
    class func presentBasicAlert(_ alert: UIAlertController) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            if let navVC = rootVC as? UINavigationController, let topVC = navVC.topViewController {
                if let modalVC = topVC.presentedViewController {
                    modalVC.present(alert, animated: true, completion: nil)
                } else {
                    topVC.present(alert, animated: true, completion: nil)
                }
            } else {
                rootVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}
