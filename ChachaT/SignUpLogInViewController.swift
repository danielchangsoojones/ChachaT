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
import ParseFacebookUtilsV4
import Alamofire

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
    
    //TODO: make logOut work for facebook
    @IBAction func facebookButtonPressed(sender: UIButton) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"]) { (user: PFUser?, error) in
            if let currentUser = user {
                if currentUser.isNew {
                    print("this is a new user that just signed up")
                    self.updateProfileFromFacebook(true)
                } else {
                    print("the user has logged in successfully!")
                    //TODO: get rid of this, only needs to be in new user area, just for my testing, so I don't need a new facebook account everytime
                    self.updateProfileFromFacebook(true)
                }
            } else {
                print("there was an error logging in/signing up")
            }
        }
    }
    
    //the API request to facebook will look something like this: graph.facebook.com/me?fields=name,email,picture
    //me is a special endpoint that somehow figures out the user's id or token, and then it can access the currentusers info like name, email and picture.
    //look into Facebook Graph API to learn more
    func updateProfileFromFacebook(isNew : Bool) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKGraphRequest(graphPath: "me?fields=name", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
                if error == nil {
                    print("updating profile from facebook")
                    let currentUser = User.currentUser()!
                    
                    let userData = result as! NSDictionary
                    print(userData)
                    currentUser.fullName = userData[Constants.name] as? String
                    currentUser.facebookId = userData[Constants.id] as? String
                    currentUser.saveInBackground()
                    
                    self.updateFacebookImage()
                } else {
                    print(error)
                }
            })
        }
    }
    
    func updateFacebookImage() {
        let currentUser = User.currentUser()!
        if let facebookId = currentUser.facebookId {
            let pictureURL = "https://graph.facebook.com/" + facebookId + "/picture?type=square&width=600&height=600"
            Alamofire.request(.GET, pictureURL).response { (request, response, data, error) -> Void in
                if error == nil && data != nil {
                    currentUser.profileImage = PFFile(name: Constants.profileImage, data: data!)
                    currentUser.saveInBackground()
                } else {
                    print("Failed to update profile image from facebook: \(error)")
                }
            }
        }
    }
    
    
    @IBAction func signUp(sender: AnyObject) {
        if allValidates() {
            if signUpState {
                signUp()
            } else {
                //logging In
                logIn()
            }
        }
    }
    
    @IBAction func changeToLoginScreen(sender: AnyObject) {
        signUpState = !signUpState
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if self.signUpState {
                self.changeScreenButton.setTitle("Or, Sign In", forState: .Normal)
                self.theFacebookButton.setTitle("Sign Up With Facebook", forState: .Normal)
                self.theSignUpButton.setTitle("Sign Up", forState: .Normal)
                self.theCreateAccountLabel.alpha = 1
                self.theTermsOfService.setTitle("Terms Of Service", forState: .Normal)
                self.theTermsOfService.setTitleColor(facebookBlue, forState: .Normal)
                self.theTermsOfService.titleLabel?.font = UIFont(name:"HelveticaNeue-Medium", size: 10)
                self.view.layoutIfNeeded()
            } else {
                self.changeScreenButton.setTitle("Or, Sign Up", forState: .Normal)
                self.theFacebookButton.setTitle("Sign In With Facebook", forState: .Normal)
                self.theSignUpButton.setTitle("Sign In", forState: .Normal)
                self.theCreateAccountLabel.alpha = 0
                self.theTermsOfService.setTitle("Forgot Password?", forState: .Normal)
                self.theTermsOfService.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                self.theTermsOfService.titleLabel?.font = UIFont(name:"HelveticaNeue", size: 12)
                self.view.layoutIfNeeded()
            }
        })
    }
    
    @IBAction func termsOfServiceButtonPressed(sender: AnyObject) {
       UIApplication.sharedApplication().openURL(NSURL(string: "http://about.chacha.com/terms-of-use/")!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setGUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        
        //hide keyboard when tap anywhere on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setGUI() {
        self.view.backgroundColor = ChachaTeal
//        applyShadow(theSignUpButton)
//        applyShadow(theFacebookButton)
        applyShadow(theTextfieldsView)
    }
    
    func applyShadow(view:UIView) {
        view.layer.shadowRadius = 2.5
        view.layer.shadowOffset = CGSizeMake(0, 1)
        view.layer.shadowColor = UIColor.grayColor().CGColor
        view.layer.shadowOpacity = 2.0
    }
    
    func hideOrUnhideFacebook(hidden: Bool) {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
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
    
    func signUp()
    {
        let currentUser = User.currentUser()
        currentUser!.username = theEmail.text
        currentUser!.password = thePassword.text
        self.view.userInteractionEnabled = false
        theSpinner.startAnimating()
        
        currentUser!.signUpInBackgroundWithBlock { (success, error) -> Void in
            self.view.userInteractionEnabled = true
            self.theSpinner.stopAnimating()
            if success {
                self.performSegueWithIdentifier(.SignUpSuccessSegue, sender: self)
                let installation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackground()
            }
            else {
                if error != nil {
                    let code = error!.code
                    if code == PFErrorCode.ErrorInvalidEmailAddress.rawValue {
                        _ = Alert(title: "Invalid Email Address", subtitle: "Please enter a valid email address.", closeButtonTitle: "Okay", closeButtonHidden: false, type: .Error)
                    }
                    else if code == PFErrorCode.ErrorUserEmailTaken.rawValue {
                        _ = Alert(title: "Problem Signing Up", subtitle: "Email already being used by another user, please use a differnet one.", closeButtonTitle: "Okay", closeButtonHidden: false, type: .Error)
                    }
                    _ = Alert(title: "Problem Signing Up", subtitle: "error:\(error!.code)", closeButtonTitle: "Okay", closeButtonHidden: false, type: .Error)
                }
            }
        }
    }
    
    func logIn() {
        view.userInteractionEnabled=false
        theSpinner.startAnimating()
        User.logInWithUsernameInBackground(theEmail.text!.lowercaseString, password: thePassword.text!) { (user, error) -> Void in
            self.theSpinner.stopAnimating()
            self.view.userInteractionEnabled=true
            
            if let error = error {
                let code = error.code
                if code == PFErrorCode.ErrorObjectNotFound.rawValue {
                    let alert = Alert(closeButtonHidden: true)
                    alert.addButton("Okay", buttonAction: { () -> Void in
                        alert.closeAlert()
                        self.theEmail.becomeFirstResponder()
                    })
                    alert.createAlert("Log In Problem", subtitle: "Username or Password is incorrect.", closeButtonTitle: "", type: .Error)
                }
                else {
                    _ = Alert(title: "Failed Login", subtitle: "Login failed at this time.", closeButtonTitle: "Okay", closeButtonHidden: false, type: .Error)
                }
                return;
            }
            
            if user != nil {
                self.performSegueWithIdentifier(.SignUpSuccessSegue, sender: self)
                let installation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveEventually(nil)
            }
        }
    }
    
    func allValidates() -> Bool
    {
        if theEmail.text!.isEmpty {
            let alert = Alert(closeButtonHidden: true)
            alert.addButton("Okay", buttonAction: { () -> Void in
                alert.closeAlert()
                self.theEmail.becomeFirstResponder()
            })
            alert.createAlert("Email is Required", subtitle: "Please enter an email address.", closeButtonTitle: "", type: .Error)
            return false
        }
        else if EFUtils.isValidEmail(theEmail.text!) == false && signUpState {
            let alert = Alert(closeButtonHidden: true)
            alert.addButton("Okay", buttonAction: { () -> Void in
                alert.closeAlert()
                self.theEmail.becomeFirstResponder()
            })
            alert.createAlert("Invalid Email", subtitle: "Please enter a valid email address", closeButtonTitle: "", type: .Error)
            return false
        }
        else if thePassword.text!.isEmpty {
            let alert = Alert(closeButtonHidden: true)
            alert.addButton("Okay", buttonAction: { () -> Void in
                alert.closeAlert()
                self.thePassword.becomeFirstResponder()
            })
            alert.createAlert("Password is Required", subtitle: "Please enter a password.", closeButtonTitle: "", type: .Error)
            return false
        }
        else {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField===self.theEmail
        {
            self.thePassword.becomeFirstResponder()
        }
        return true
    }
    
}

//keyboard notification
extension SignUpLogInViewController {
    func keyboardWillShow(notification: NSNotification) {
        guard let bottomConstraint = changeScreenButtonBottomConstraint else { return }
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                //tab bar height is default by Apple at 49
                let originalHeight = CGFloat(20)
                bottomConstraint.constant = keyboardSize.height + originalHeight
                self.hideOrUnhideFacebook(true)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let bottomConstraint = changeScreenButtonBottomConstraint else { return }
        bottomConstraint.constant = 20
        self.hideOrUnhideFacebook(false)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}
