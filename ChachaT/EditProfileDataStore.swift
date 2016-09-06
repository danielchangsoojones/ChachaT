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
            currentUser[parseColumnName] = file
        }
    }
    
    func bulletPointWasEdited(text: String, bulletPointNumber: Int) {
        let prefix = "bulletPoint"
        let suffix = bulletPointNumber.toString
        let parseColumnName = prefix + suffix
        currentUser[parseColumnName] = text
    }
}


