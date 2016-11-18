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
    func loadBulletPoint(_ text: String, num: Int)
    func loadProfileImage(_ file: AnyObject,num: Int)
    func loadText(_ text: String, title: String)
    func finishedSaving()
}

class EditProfileDataStore {
    let currentUser = User.current()!
    var delegate: EditProfileDataStoreDelegate?
    
    init(delegate: EditProfileDataStoreDelegate) {
        self.delegate = delegate
    }
    
    func saveEverything() {
        currentUser.saveInBackground { (success, error) in
            if success && error == nil {
                print("successfully saved user")
            } else {
                print("error")
            }
            self.delegate?.finishedSaving()
        }
    }
    
    func saveProfileImage(_ image: UIImage, photoNumber: Int) {
        let file = PFFile(name: "profileImage.jpg",data: UIImageJPEGRepresentation(image, 0.6)!)
        let parseColumnName = getProfileImageParseColumnName(imageNumber: photoNumber)
        //dangerous to save parse things this way because it will create a new column no matter if the data model was supposed to be named that
        currentUser[parseColumnName] = file
    }
    
    func deleteImage(photoNumber: Int) {
        let parseColumnName = getProfileImageParseColumnName(imageNumber: photoNumber)
        currentUser.remove(forKey: parseColumnName)
    }
    
    func getProfileImageParseColumnName(imageNumber: Int) -> String {
        let prefix = "profileImage"
        if imageNumber == 1 {
            //the first profileImage is just saved in parse as:
            return "profileImage"
        } else {
            return getParseColumnName(prefix, num: imageNumber)
        }
    }
    
    func textFieldWasEdited(_ text: String, title: String) {
        switch title {
        case EditProfileConstants.fullNameTitle:
            currentUser.fullName = text
        case EditProfileConstants.schoolOrJobTitle:
            currentUser.title = text
        default:
            break
        }
    }
    
    func bulletPointWasEdited(_ text: String, bulletPointNumber: Int) {
        let prefix = "bulletPoint"
        let parseColumnName = getParseColumnName(prefix, num: bulletPointNumber)
        //dangerous to save parse things this way because it will create a new column no matter if the data model was supposed to be named that
        currentUser[parseColumnName] = text
    }
    
    func getParseColumnName(_ prefix: String, num: Int) -> String {
        let suffix = num.toString
        let parseColumnName = prefix + suffix
        return parseColumnName
    }
    
    func saveAge(_ birthday: Date) {
        currentUser.birthDate = birthday
    }
    
    func saveHeight(height: Int) {
        currentUser.height = height
    }
}

//loading values extension
extension EditProfileDataStore {
    func loadEverything() {
        loadBulletPoints()
        loadTexts()
    }
    
    func loadProfileImages() {
        //TODO: probably need to resize these images when I bring them down, no use in using full size image, when we just want it for this size.
        for index in 1...PhotoEditingViewConstants.numberOfPhotoViews {
            //TODO: make the string profileImage be relative to something real
            let parseColumnName = getProfileImageParseColumnName(imageNumber: index)
            if let file = currentUser[parseColumnName] {
                delegate?.loadProfileImage(file as AnyObject, num: index)
            }
        }
    }
    
    func loadBulletPoints() {
        for index in 1...EditProfileConstants.numberOfBulletPoints {
            //TODO: make the string bulletPoint be relative to something real
            let parseColumnName = getParseColumnName("bulletPoint", num: index)
            if let description = currentUser[parseColumnName] as? String , !description.isEmpty {
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
        delegate?.loadText(currentUser.gender, title: EditProfileConstants.genderTitle)
        if let age = currentUser.age {
            delegate?.loadText(age.toString, title: EditProfileConstants.ageTitle)
        }
    }
}


