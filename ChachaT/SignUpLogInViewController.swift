//
//  SignUpTwoViewController.swift
//  Chacha
//
//  Created by Daniel Jones on 4/1/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EFTools
import Parse
import SnapKit
import SCLAlertView

class SignUpLogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var theEmail: UITextField!
    @IBOutlet weak var thePassword: UITextField!
    @IBOutlet weak var theSignUpButton: UIButton!
    @IBOutlet weak var theFacebookButton: UIButton!
    @IBOutlet weak var theTextfieldsView: UIView!
    @IBOutlet weak var theSpinner: UIActivityIndicatorView!
    @IBOutlet weak var orLine: UIImageView!
    @IBOutlet weak var theFacebookLogo: UIImageView!
    @IBOutlet weak var theCreateAccountLabel: UILabel!
    @IBOutlet weak var theTermsOfService: UIButton!
    @IBOutlet weak var changeScreenButton: UIButton!
    
    //constraint outlets
    @IBOutlet weak var changeScreenButtonBottomConstraint: NSLayoutConstraint!
    
    
    var signUpState = true
    var dataNegotiator: WelcomeDataNegotiator!
    
    //TODO: make logOut work for facebook
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        
        
        
        dataNegotiator.accessFaceBook()
    }
    
    
    @IBAction func signUp(_ sender: AnyObject) {
        if allValidates() {
            if signUpState {
                signUp()
            } else {
                //logging In
                logIn()
            }
        }
    }
    
    @IBAction func changeToLoginScreen(_ sender: AnyObject) {
        signUpState = !signUpState
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            if self.signUpState {
                self.changeScreenButton.setTitle("Or, Sign In", for: UIControlState())
                self.theFacebookButton.setTitle("Sign Up With Facebook", for: UIControlState())
                self.theSignUpButton.setTitle("Sign Up", for: UIControlState())
                self.theCreateAccountLabel.alpha = 1
                self.theTermsOfService.setTitle("Terms Of Service", for: UIControlState())
                self.theTermsOfService.setTitleColor(facebookBlue, for: UIControlState())
                self.theTermsOfService.titleLabel?.font = UIFont(name:"HelveticaNeue-Medium", size: 10)
                self.view.layoutIfNeeded()
            } else {
                self.changeScreenButton.setTitle("Or, Sign Up", for: UIControlState())
                self.theFacebookButton.setTitle("Sign In With Facebook", for: UIControlState())
                self.theSignUpButton.setTitle("Sign In", for: UIControlState())
                self.theCreateAccountLabel.alpha = 0
                self.theTermsOfService.setTitle("Forgot Password?", for: UIControlState())
                self.theTermsOfService.setTitleColor(UIColor.white, for: UIControlState())
                self.theTermsOfService.titleLabel?.font = UIFont(name:"HelveticaNeue", size: 12)
                self.view.layoutIfNeeded()
            }
        })
    }
    
    @IBAction func termsOfServiceButtonPressed(_ sender: AnyObject) {
       UIApplication.shared.openURL(URL(string: "http://about.chacha.com/terms-of-use/")!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataNegotiator = WelcomeDataNegotiator(delegate: self)
        setGUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        setupTapAwayFromKeyboard()
    }
    
    //When the user taps away from the keyboard dismiss the keyboard
    func setupTapAwayFromKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpLogInViewController.dismissTheKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissTheKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setGUI() {
        self.view.backgroundColor = ChachaTeal
        applyShadow(theTextfieldsView)
    }
    
    func applyShadow(_ view:UIView) {
        view.layer.shadowRadius = 2.5
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 2.0
    }
    
    func hideOrUnhideFacebook(_ hidden: Bool) {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                if hidden {
                    self.theFacebookButton.alpha = 0
                    self.orLine.alpha = 0
                    self.theFacebookLogo.alpha = 0
                    self.theCreateAccountLabel.alpha = 0
                    self.theTermsOfService.alpha = 0
                } else {
                    self.theFacebookButton.alpha = 1
                    self.orLine.alpha = 1
                    self.theFacebookLogo.alpha = 1
                    self.theTermsOfService.alpha = 1
                    if self.signUpState {
                        self.theCreateAccountLabel.alpha = 1
                    }
                }
            })
    }
    
    func signUp() {
        if let email = theEmail.text, let password = thePassword.text {
            dataNegotiator.signUp(email: email, password: password)
        } else {
            _ = SCLAlertView().showError("Invalid Email/Password", subTitle: "Please enter an email/password", closeButtonTitle: "Okay")
        }
    }
    
    func logIn() {
        if let email = theEmail.text, let password = thePassword.text {
            dataNegotiator.logIn(email: email, password: password)
        } else {
            _ = SCLAlertView().showError("Invalid Email/Password", subTitle: "Please enter an email/password", closeButtonTitle: "Okay")
        }
    }
    
    func allValidates() -> Bool
    {
        if theEmail.text!.isEmpty {
            alertAndBecomeResponder(title: "Email is Required", subtitle: "Please enter an email address.", action: { 
                self.theEmail.becomeFirstResponder()
            })
            return false
        } else if EFUtils.isValidEmail(theEmail.text!) == false && signUpState {
            alertAndBecomeResponder(title: "Invalid Email", subtitle: "Please enter a valid email address", action: {
                self.theEmail.becomeFirstResponder()
            })
            return false
        } else if let password = thePassword.text, password.isEmpty {
            alertAndBecomeResponder(title: "Password is Required", subtitle: "Please enter a password.", action: {
                self.thePassword.becomeFirstResponder()
            })
            return false
        }
        else {
            return true
        }
    }
    
    func alertAndBecomeResponder(title: String, subtitle: String, action: @escaping () -> ()) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        _ = alertView.addButton("Okay", action: {
            let responder: SCLAlertViewResponder = SCLAlertViewResponder(alertview: alertView)
            responder.close()
            action()
        })
        _ = alertView.showError(title, subTitle: subtitle)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField===self.theEmail
        {
            self.thePassword.becomeFirstResponder()
        }
        return true
    }
    
}

//keyboard notification
extension SignUpLogInViewController {
    func keyboardWillShow(_ notification: Notification) {
        guard let bottomConstraint = changeScreenButtonBottomConstraint else { return }
        if let userInfo = (notification as NSNotification).userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                //tab bar height is default by Apple at 49
                let originalHeight = CGFloat(20)
                bottomConstraint.constant = keyboardSize.height + originalHeight
                self.hideOrUnhideFacebook(true)
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let bottomConstraint = changeScreenButtonBottomConstraint else { return }
        bottomConstraint.constant = 20
        self.hideOrUnhideFacebook(false)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}

extension SignUpLogInViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case SignUpSuccessSegue
        case SignUpToQuestionOnboardingSegue
    }
}
