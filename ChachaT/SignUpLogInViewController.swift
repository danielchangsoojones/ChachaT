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
    
    //TODO: make logOut work for facebook
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email"]) { (user, error) in
            if let currentUser = user as? User {
                if currentUser.isNew {
                    print("this is a new user that just signed up")
                    self.updateProfileFromFacebook(true)
                } else {
                    //let the facebook user sign-in
                    self.performSegueWithIdentifier(.SignUpSuccessSegue, sender: nil)
                }
            } else {
                print("there was an error logging in/signing up")
            }
        }
    }
    
    //the API request to facebook will look something like this: graph.facebook.com/me?fields=name,email,picture
    //me is a special endpoint that somehow figures out the user's id or token, and then it can access the currentusers info like name, email and picture.
    //look into Facebook Graph API to learn more
    func updateProfileFromFacebook(_ isNew : Bool) {
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me?fields=name", parameters: nil).start(completionHandler: { (connection, result, error) -> Void in
                if error == nil {
                    print("updating profile from facebook")
                    let currentUser = User.current()!
                    
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
        let currentUser = User.current()!
        if let facebookId = currentUser.facebookId {
            let pictureURL = "https://graph.facebook.com/" + facebookId + "/picture?type=square&width=600&height=600"
            Alamofire.request(pictureURL).responseData(completionHandler: { (response) in
                if response.result.error == nil {
                    let data = response.result.value
                    currentUser.profileImage = PFFile(name: Constants.profileImage, data: data!)
                    currentUser.saveInBackground()
                    self.performSegueWithIdentifier(.SignUpSuccessSegue, sender: self)
                } else {
                    print("Failed to update profile image from facebook: \(response.result.error)")
                }
            })
        }
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
        setGUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //hide keyboard when tap anywhere on screen
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
//        applyShadow(theSignUpButton)
//        applyShadow(theFacebookButton)
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
    
    func signUp()
    {
        let currentUser = User.current()
        currentUser!.username = theEmail.text
        currentUser!.password = thePassword.text
        self.view.isUserInteractionEnabled = false
        theSpinner.startAnimating()

        currentUser!.signUpInBackground { (success, error: Error?) -> Void in
            self.view.isUserInteractionEnabled = true
            self.theSpinner.stopAnimating()
            if success {
                self.performSegueWithIdentifier(.SignUpSuccessSegue, sender: self)
                let installation = PFInstallation.current()
                installation!["user"] = PFUser.current()
                installation!.saveInBackground()
            }
            else {
                if error != nil {
                    let code = error!._code
                    if code == PFErrorCode.errorInvalidEmailAddress.rawValue {
                        _ = SCLAlertView().showError("invalid Email Address", subTitle: "Please enter a valid email address.", closeButtonTitle: "Okay")
                    } else if code == PFErrorCode.errorUserEmailTaken.rawValue {
                        _ = SCLAlertView().showError("Problem Signing Up", subTitle: "Email already being used by another user, please use a differnet one.", closeButtonTitle: "Okay")
                    } else {
                        _ = SCLAlertView().showError("Problem Signing Up", subTitle: "error:\(code)", closeButtonTitle: "Okay")
                    }
                }
            }
        }
    }
    
    func logIn() {
        view.isUserInteractionEnabled=false
        theSpinner.startAnimating()
        User.logInWithUsername(inBackground: theEmail.text!.lowercased(), password: thePassword.text!) { (user, error) -> Void in
            self.theSpinner.stopAnimating()
            self.view.isUserInteractionEnabled=true
            
            if let error = error {
                let code = error._code
                if code == PFErrorCode.errorObjectNotFound.rawValue {
                    self.alertAndBecomeResponder(title: "Log In Problem", subtitle: "Username or Password is incorrect.", action: { 
                        self.theEmail.becomeFirstResponder()
                    })
                }
                else {
                    _ = SCLAlertView().showError("Failed Login", subTitle: "Login failed at this time.", closeButtonTitle: "Okay")
                }
                return;
            }
            
            if user != nil {
                self.performSegueWithIdentifier(.SignUpSuccessSegue, sender: self)
                let installation = PFInstallation.current()
                installation!["user"] = PFUser.current()
                installation!.saveEventually(nil)
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
