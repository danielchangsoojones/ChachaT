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

extension EditProfileViewController: GBHFacebookImagePickerDelegate {
    func showFacebookImagePicker() {
        let picker = GBHFacebookImagePicker()
        picker.presentFacebookAlbumImagePicker(from: self, delegate: self)
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
