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
import SCLAlertView
import ALCameraViewController

protocol CameraDelegate {
    func imageWasPicked(image: UIImage)
}

class Camera {
    var delegate: CameraDelegate?
    
    init(delegate: CameraDelegate) {
        self.delegate = delegate
    }

    class func shouldStartCamera(target: AnyObject, canEdit: Bool, frontFacing: Bool) -> Bool {
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
            //user gave permission for use to use their camera
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
        } else {
            //permission has not been granted
             let _ = SCLAlertView().showInfo("Camera Denied", subTitle: "please go to iphone settings -> ShuffleHunt to allow us access to your camera")
            return false
        }
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

//extension for specialty camera view that can crop
extension Camera {
    //Using this special image picker forces the user to crop the photo, the crop is a square
    func presentCroppingPhotoLibraryVC(target: AnyObject) {
        //TODO: fix the weak stuff that is on the github that says we need to do.
        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled: true) { [weak target] image, asset in
            self.imageWasPicked(image: image, target: target!)
        }
        
        target.present(libraryViewController, animated: true, completion: nil)
    }
    
    func presentCroppingCameraVC(target: AnyObject) {
        let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak target] image, asset in
            self.imageWasPicked(image: image, target: target!)
        }
        
        target.present(cameraViewController, animated: true, completion: nil)
    }
    
    fileprivate func imageWasPicked(image: UIImage?, target: AnyObject) {
        if let image = image {
            let dimension: CGFloat = 400
            let resizedImage = image.resizeImage(targetSize: CGSize(width: dimension, height: dimension))
            self.delegate?.imageWasPicked(image: resizedImage)
        }
        target.dismiss(animated: true, completion: nil)
    }
}
