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
import Timepiece

class WelcomeDataStore {
    var delegate: WelcomeDataStoreDelegate?
    
    init(delegate: WelcomeDataStoreDelegate) {
        self.delegate = delegate
    }
}

//for signing up
extension WelcomeDataStore {
    func signUp(email: String, password: String) {
        let newUser = User()
        newUser.username = email
        newUser.password = password
        newUser.email = email
        delegate?.toggleSpinner(hide: false)
        
        newUser.signUpInBackground { (success, error: Error?) -> Void in
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
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email", "user_photos", "user_birthday", "user_education_history", "user_work_history"]) { (user, error) in
            if let currentUser = user as? User {
                if currentUser.isNew {
                    print("this is a new user that just signed up")
                    self.updateProfileFromFacebook(true)
                } else {
                    //let the facebook user sign-in
                    self.updateProfileFromFacebook(false)
//                    self.delegate?.performSegueIntoApp()
                }
            } else if let error = error {
                print(error)
            }
        }
    }
    
    //the API request to facebook will look something like this: graph.facebook.com/me?fields=name,email,picture
    //me is a special endpoint that somehow figures out the user's id or token, and then it can access the currentusers info like name, email and picture.
    //look into Facebook Graph API to learn more
    private func updateProfileFromFacebook(_ isNew : Bool) {
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, birthday, education, work"]).start(completionHandler: { (connection, result, error) -> Void in
                if error == nil {
                    print("updating profile from facebook")
                    let currentUser = User.current()!
                    
                    let userData = result as! NSDictionary
                    if currentUser.fullName == nil || currentUser.fullName == "" {
                        currentUser.fullName = userData[Constants.name] as? String
                    }
                    currentUser.facebookId = userData[Constants.id] as? String
                    currentUser.birthDate = self.extractBirthdate(userData: userData)
                    currentUser.email = userData["email"] as? String
                    if currentUser.title == nil || currentUser.title == "" {
                        //don't change the user's title when they are logging back in, if they have already set it to something
                        currentUser.title = self.extractSchoolName(userData: userData)
                        if self.extractSchoolName(userData: userData) == nil {
                            //if we can't find a school name, then see if they have a workplace
                            currentUser.title = self.extractWork(userData: userData)
                        }
                    }
                    currentUser.saveInBackground()
                    
                    self.updateFacebookImage()
                } else if let error = error {
                    print(error)
                }
            })
        }
    }
    
    fileprivate func extractSchoolName(userData: NSDictionary) -> String? {
        let education = userData["education"]
        
        //each school that a facebook user has listed, has its own dictionary for that school where it tells things like type of school, name, id, etc. So, we need to go through each school and then create a dictionary for each school. But, we really only want the user's most recent school, so we get the last school because we don't really care if the user's middle school, if they are in college now.
        if let educationDictionary = education as? [NSDictionary] {
            if let mostCurrentEducationDictionary = educationDictionary.last, let schoolDictionary = mostCurrentEducationDictionary.object(forKey: "school") as? NSDictionary {
                return schoolDictionary.object(forKey: "name") as! String?
            }
        }
        return nil
    }
    
    fileprivate func extractBirthdate(userData: NSDictionary) -> Date? {
        if let birthday = userData["birthday"] as? String {
            return birthday.date(inFormat: "MM/dd/yyyy")
        }
        return nil
    }
    
    fileprivate func extractWork(userData: NSDictionary) -> String? {
        let work = userData["work"]
        //each workplace that a facebook user has listed, has its own dictionary for that workplace where it tells things like employer, location, etc. So, we need to go through each workplace and then create a dictionary for each workplace. But, we really only want the user's most recent work, so we get the last workplace because we don't really care if the user's 5 year ago job, if they are working somewhere else now.
        if let workDictionary = work as? [NSDictionary], let mostCurrentWorkplace = workDictionary.last {
            if let employer = mostCurrentWorkplace.object(forKey: "employer") as? NSDictionary {
                return employer.object(forKey: "name") as! String?
            }
        }
        return nil
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

extension WelcomeDataStore {
    func performPasswordRecovery(email: String) {
        if email.isEmail {
            User.requestPasswordResetForEmail(inBackground: email, block: { (success, error) in
                if success {
                    SCLAlertView().showSuccess("Email Sent", subTitle: "The email could take a couple of minutes to send", closeButtonTitle: "Okay")
                } else if let _ = error {
                    SCLAlertView().showInfo("Error", subTitle: "No matching email was found", closeButtonTitle: "Okay")
                }
            })
        } else {
            //not an email for username, so logged in via facebook
            print("not an email for username, so logged in via facebook")
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
