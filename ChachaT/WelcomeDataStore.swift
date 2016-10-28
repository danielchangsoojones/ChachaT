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
        let newUser = User()
        newUser.username = email
        newUser.password = password
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
                self.cleanDatabaseTags()
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
    
    //Purpose: this will eventually be removed. So, when I got some real users, I (Daniel Jones) accidentally still had the code saving tags to the Tags class, so the  I tried to convert them to the updated database. But, I can't save/edit a user without logging in as them, and I need to be able to edit the user's relation. So, this is a hacky fix. Once the user logs in, then it will look over the join table and convert them to my updated database, then once I have converted all the users obselete tags, I can get rid of the Tags class. Overtime, if those users log back in, then this will fix the problem...
    fileprivate func cleanDatabaseTags() {
        let query = Tags.query()! as! PFQuery<Tags>
        //This user was one of the beginning users who got messed up
        query.whereKey("createdBy", equalTo: User.current()!)
        query.getFirstObjectInBackground { (tag: Tags?, error) in
            if let tag = tag {
                self.findJointUserTags(tag: tag)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    fileprivate func findJointUserTags(tag: Tags) {
        let query = JointParseTagToUser.query()! as! PFQuery<JointParseTagToUser>
        query.whereKey("user", equalTo: User.current()!)
        query.includeKey("parseTag")
        query.findObjectsInBackground { (joints, error) in
            if let joints = joints {
                for joint in joints {
                    let relation = User.current()!.relation(forKey: "tags")
                    relation.add(joint.parseTag)
                }
                User.current()!.saveInBackground()
                tag.deleteInBackground()
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
