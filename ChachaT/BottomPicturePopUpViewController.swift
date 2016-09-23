//
//  BottomPicturePopUpViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

protocol BottomPicturePopUpViewControllerDelegate {
    func passImage(_ image: UIImage)
}

class BottomPicturePopUpViewController: UIViewController {
    
    @IBOutlet weak var thePhotoLibraryButton: UIButton!
    @IBOutlet weak var theCameraButton: UIButton!
    
    var profileImageSize : CGSize?
    
    var bottomPicturePopUpViewControllerDelegate : BottomPicturePopUpViewControllerDelegate?
    
    @IBAction func thePhotoLibraryButtonPressed(_ sender: AnyObject) {
        setImagePickerDelegate(UIImagePickerControllerSourceType.photoLibrary)
    }

    @IBAction func theCameraButtonPressed(_ sender: AnyObject) {
        setImagePickerDelegate(UIImagePickerControllerSourceType.camera)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let extraHeight : CGFloat = 45
        contentSizeInPopup = CGSize(width: self.view.bounds.width, height: thePhotoLibraryButton.frame.height + theCameraButton.frame.height + extraHeight)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BottomPicturePopUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func setImagePickerDelegate(_ pickerType: UIImagePickerControllerSourceType) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = pickerType;
        imgPicker.allowsEditing = true
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!)
    {
        if image != nil {
            //would like to resize the image, but it was creating bars around the image. Will have to analyze the resizeImage function
//            let resizedImage = image.resizeImage(profileImageSize!)
            bottomPicturePopUpViewControllerDelegate?.passImage(image)
            dismissCurrentViewController()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissCurrentViewController() {
        //in the imagePickerController, it thought the current view controller was the image picker, so it wasn't dismissing the bottom pop up controller. This fixed that.
        self.dismiss(animated: true, completion: nil)
    }
}
