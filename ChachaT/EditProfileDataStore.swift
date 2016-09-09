//
//  EditProfileDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

protocol EditProfileDataStoreDelegate {
    
}

class EditProfileDataStore {
    let currentUser = User.currentUser()!
    
    func saveEverything() {
        currentUser.saveInBackgroundWithBlock { (success, error) in
            if success && error == nil {
                print("successfully saved user")
            } else {
                print("error")
            }
        }
    }
    
    func saveProfileImage(image: UIImage, photoNumber: Int) {
        let file = PFFile(name: "profileImage.jpg",data: UIImageJPEGRepresentation(image, 0.6)!)
        let prefix = "profileImage"
        if photoNumber == 1 {
            currentUser.profileImage = file
        } else {
            let suffix = photoNumber.toString
            let parseColumnName = prefix + suffix
            //dangerous to save parse things this way because it will create a new column no matter if the data model was supposed to be named that
            currentUser[parseColumnName] = file
        }
    }
    
    func textFieldWasEdited(text: String, title: String) {
        switch title {
        case EditProfileConstants.fullNameTitle:
            currentUser.fullName = text
        case EditProfileConstants.schoolOrJobTitle:
            currentUser.title = text
        default:
            break
        }
    }
    
    func bulletPointWasEdited(text: String, bulletPointNumber: Int) {
        let prefix = "bulletPoint"
        let suffix = bulletPointNumber.toString
        let parseColumnName = prefix + suffix
        //dangerous to save parse things this way because it will create a new column no matter if the data model was supposed to be named that
        currentUser[parseColumnName] = text
    }
    
    func saveAge(birthday: NSDate) {
        currentUser.birthDate = birthday
        //saving birthdate in two places in database because it will make querying easier with tags.
        let tag = Tags()
        tag.birthDate = birthday
        tag.saveInBackground()
    }
}


