//
//  Camera.swift
//  iLikeyiOS
//
//  Created by Ross Barbish on 7/10/2015
//  Copyright (c) 2015 NoShoes Labs. All rights reserved.
//


import UIKit
import MobileCoreServices
import JSQMessagesViewController
import AVFoundation

class Camera {
    
    class func shouldStartCamera(target: AnyObject, canEdit: Bool, frontFacing: Bool) -> Bool {
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
            //user gave permission for use to use their camera
            print("user has given access to their camera")
        } else {
            //permission has not been granted
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true
                {
                    // User granted
                    print("user granted access")
                }
                else
                {
                    // User Rejected
                    print("user has denied")
                }
            })
        }
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == false {
            return false
        }
        
        let type = kUTTypeImage as String
        let cameraUI = UIImagePickerController()
        
        let available = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) && (UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.camera) as [String]!).contains(type)
        
        if available {
            cameraUI.mediaTypes = [type]
            cameraUI.sourceType = UIImagePickerControllerSourceType.camera
            
            /* Prioritize front or rear camera */
            if (frontFacing == true) {
                if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front) {
                    cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.front
                } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) {
                    cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.rear
                }
            } else {
                if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) {
                    cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.rear
                } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front) {
                    cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.front
                }
            }
        } else {
            return false
        }
        
        cameraUI.allowsEditing = canEdit
        cameraUI.showsCameraControls = true
        if let delegate = target as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
            cameraUI.delegate = delegate
        }
        target.present(cameraUI, animated: true, completion: nil)
        
        return true
    }

    class func shouldStartPhotoLibrary(target: AnyObject, canEdit: Bool) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            return false
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) && (UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.savedPhotosAlbum) as [String]!).contains(type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        }
        else {
            return false
        }
        
        imagePicker.allowsEditing = canEdit
        if let delegate = target as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
            imagePicker.delegate = delegate
        }
        target.present(imagePicker, animated: true, completion: nil)
        
        return true
    }
    
    class func shouldStartVideoLibrary(target: AnyObject, canEdit: Bool) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            return false
        }
        
        let type = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) && (UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.savedPhotosAlbum) as [String]!).contains(type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        }
        else {
            return false
        }
        
        imagePicker.videoMaximumDuration = 30
        imagePicker.videoQuality = UIImagePickerControllerQualityType.typeLow
        imagePicker.allowsEditing = canEdit
        if let delegate = target as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
            imagePicker.delegate = delegate
        }
        target.present(imagePicker, animated: true, completion: nil)
        
        return true
    }
}
