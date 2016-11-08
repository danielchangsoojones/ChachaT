//
//  FacebookImagePickerExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/31/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import GBHFacebookImagePicker
import SCLAlertView
import ParseFacebookUtilsV4

extension EditProfileViewController: GBHFacebookImagePickerDelegate {
    func showFacebookImagePicker() {
        let picker = GBHFacebookImagePicker()
        
        if let fbAccessToken = FBSDKAccessToken.current(), fbAccessToken.permissions.isEmpty {
            FBSDKAccessToken.refreshCurrentAccessToken({ (_, _, error) in
                if error == nil {
                    //we must refresh the access token in order to see the permissions, then in the GBHFacebookImagePicker, it checks whether we have the permission, otherwise it would re-login the user.
                    picker.presentFacebookAlbumImagePicker(from: self, delegate: self)
                } else if let error = error {
                    _ = SCLAlertView().showInfo("Facebook Error", subTitle: error.localizedDescription)
                }
            })
        } else {
            //the user is not logged in via Facebook, or the permissions are already available for use, in which case we can just present the picker like normally where an email user would be asked to login w/ Facebook, and the Facebook user would just go right ahead. Somehow, if the user is logged in via email, it still goes to the facebook website for the last logged in user on facebook. Like Safari is caching this user, which is nice because that means even if they signed in via email to the app, they could still access their facebook photos quickly, assuming they had logged in on safari
            picker.presentFacebookAlbumImagePicker(from: self, delegate: self)
        }
    }
    
    func facebookImagePicker(imagePicker: UIViewController, didSelectImage image: UIImage?, WithUrl url: String) {
        //TODO: this image is not that large, so we might need to resend a request to facebook to get a bigger picture that we can expand later.
        imageWasPicked(image: image, picker: imagePicker)
    }
    
    func facebookImagePicker(imagePicker: UIViewController, didFailWithError error: Error?) {
        imagePicker.dismiss(animated: true, completion: {
            _ = SCLAlertView().showError("Facebook Error", subTitle: "The image from facebook could not be retrieved. Please try again")
        })
    }
    
    func facebookImagePicker(didCancelled imagePicker: UIViewController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
