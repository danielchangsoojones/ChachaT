//
//  WelcomeDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/26/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import ParseFacebookUtilsV4
import Alamofire
import SCLAlertView

class WelcomeDataStore {
    var delegate: WelcomeDataStoreDelegate?
    
    init(delegate: WelcomeDataStoreDelegate) {
        self.delegate = delegate
    }
}

//for signing up
extension WelcomeDataStore {
    func signUp(email: String, password: String) {
        let currentUser = User.current()
        currentUser!.username = email
        currentUser!.password = password
        delegate?.toggleSpinner(hide: false)
        
        currentUser!.signUpInBackground { (success, error: Error?) -> Void in
            self.delegate?.toggleSpinner(hide: true)
            if success {
                let installation = PFInstallation.current()
                installation!["user"] = PFUser.current()
                installation!.saveInBackground()
                self.delegate?.performSegueIntoApp()
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
}

//for logging in
extension WelcomeDataStore {
    func logIn(email: String, password: String) {
        let lowerCaseEmail = email.lowercased()
        let lowerCasePassword = password.lowercased()
        
        delegate?.toggleSpinner(hide: false)
        
        User.logInWithUsername(inBackground: lowerCaseEmail, password: lowerCasePassword) { (user, error) -> Void in
            self.delegate?.toggleSpinner(hide: true)
            
            if let _ = user, error == nil {
                let installation = PFInstallation.current()
                installation!["user"] = PFUser.current()
                installation!.saveEventually(nil)
                self.delegate?.performSegueIntoApp()
            } else if let error = error {
                let code = error._code
                if code == PFErrorCode.errorObjectNotFound.rawValue {
                    self.delegate?.userNotFound()
                } else {
                    _ = SCLAlertView().showError("Failed Login", subTitle: "Login failed at this time.", closeButtonTitle: "Okay")
                }
            }
        }
    }
}

//Facebook Extension
extension WelcomeDataStore {
    //Facebook log in is not currently working at the moment, and I am not totally sure why...
    func accessFaceBook() {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email"]) { (user, error) in
            if let currentUser = user as? User {
                if currentUser.isNew {
                    print("this is a new user that just signed up")
                    self.updateProfileFromFacebook(true)
                } else {
                    //let the facebook user sign-in
                    self.delegate?.performSegueIntoApp()
                }
            } else {
                print(error)
            }
        }
    }
    
    //the API request to facebook will look something like this: graph.facebook.com/me?fields=name,email,picture
    //me is a special endpoint that somehow figures out the user's id or token, and then it can access the currentusers info like name, email and picture.
    //look into Facebook Graph API to learn more
    private func updateProfileFromFacebook(_ isNew : Bool) {
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
    
    private func updateFacebookImage() {
        let currentUser = User.current()!
        if let facebookId = currentUser.facebookId {
            let pictureURL = "https://graph.facebook.com/" + facebookId + "/picture?type=square&width=600&height=600"
            Alamofire.request(pictureURL).responseData(completionHandler: { (response) in
                if response.result.error == nil {
                    let data = response.result.value
                    currentUser.profileImage = PFFile(name: Constants.profileImage, data: data!)
                    currentUser.saveInBackground()
                    self.delegate?.performSegueIntoApp()
                } else {
                    print("Failed to update profile image from facebook: \(response.result.error)")
                }
            })
        }
    }
}

protocol WelcomeDataStoreDelegate {
    func performSegueIntoApp()
    func toggleSpinner(hide: Bool)
    func userNotFound()
}

extension SignUpLogInViewController: WelcomeDataStoreDelegate {
    func performSegueIntoApp() {
        performSegueWithIdentifier(.SignUpSuccessSegue, sender: nil)
    }
    
    func toggleSpinner(hide: Bool) {
        //while the spinner is going, we don't want the user button mashing stuff.
        self.view.isUserInteractionEnabled = hide
        if hide {
            theSpinner.stopAnimating()
        } else {
            theSpinner.startAnimating()
        }
    }
    
    func userNotFound() {
        self.alertAndBecomeResponder(title: "Log In Problem", subtitle: "Username or Password is incorrect.", action: {
            self.theEmail.becomeFirstResponder()
        })
    }
}
