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
    func loadBulletPoint(text: String, num: Int)
    func loadProfileImage(file: AnyObject,num: Int)
    func loadText(text: String, title: String)
}

class EditProfileDataStore {
    let currentUser = User.currentUser()!
    var delegate: EditProfileDataStoreDelegate?
    
    init(delegate: EditProfileDataStoreDelegate) {
        self.delegate = delegate
    }
    
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
        let parseColumnName = getProfileImageParseColumnName(prefix, imageNumber: photoNumber)
        //dangerous to save parse things this way because it will create a new column no matter if the data model was supposed to be named that
        currentUser[parseColumnName] = file
    }
    
    func getProfileImageParseColumnName(prefix: String, imageNumber: Int) -> String {
        if imageNumber == 1 {
            //the first profileImage is just saved in parse as:
            return "profileImage"
        } else {
            return getParseColumnName(prefix, num: imageNumber)
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
        let parseColumnName = getParseColumnName(prefix, num: bulletPointNumber)
        //dangerous to save parse things this way because it will create a new column no matter if the data model was supposed to be named that
        currentUser[parseColumnName] = text
    }
    
    func getParseColumnName(prefix: String, num: Int) -> String {
        let suffix = num.toString
        let parseColumnName = prefix + suffix
        return parseColumnName
    }
    
    func saveAge(birthday: NSDate) {
        currentUser.birthDate = birthday
        //saving birthdate in two places in database because it will make querying easier with tags.
        let tag = Tags()
        tag.birthDate = birthday
        tag.saveInBackground()
    }
}

//loading values extension
extension EditProfileDataStore {
    func loadEverything() {
        loadProfileImages()
        loadBulletPoints()
        loadTexts()
    }
    
    func loadProfileImages() {
        //TODO: probably need to resize these images when I bring them down, no use in using full size image, when we just want it for this size.
        for index in 1...PhotoEditingViewConstants.numberOfPhotoViews {
            //TODO: make the string profileImage be relative to something real
            let parseColumnName = getProfileImageParseColumnName("profileImage", imageNumber: index)
            if let file = currentUser[parseColumnName] {
                delegate?.loadProfileImage(file, num: index)
            }
        }
    }
    
    func loadBulletPoints() {
        for index in 1...EditProfileConstants.numberOfBulletPoints {
            //TODO: make the string bulletPoint be relative to something real
            let parseColumnName = getParseColumnName("bulletPoint", num: index)
            if let description = currentUser[parseColumnName] as? String where !description.isEmpty {
                delegate?.loadBulletPoint(description, num: index)
            }
        }
    }
    
    func loadTexts() {
        if let fullName = currentUser.fullName {
            delegate?.loadText(fullName, title: EditProfileConstants.fullNameTitle)
        }
        if let schoolOrJobTitle = currentUser.title {
            delegate?.loadText(schoolOrJobTitle, title: EditProfileConstants.schoolOrJobTitle)
        }
        if let age = currentUser.age {
            delegate?.loadText(age.toString, title: EditProfileConstants.ageTitle)
        }
    }
}


