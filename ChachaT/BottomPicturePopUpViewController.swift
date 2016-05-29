//
//  BottomPicturePopUpViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

protocol BottomPicturePopUpViewControllerDelegate {
    func passImage(image: UIImage)
}

class BottomPicturePopUpViewController: UIViewController {
    
    @IBOutlet weak var thePhotoLibraryButton: UIButton!
    @IBOutlet weak var theCameraButton: UIButton!
    
    var profileImageSize : CGSize?
    
    var bottomPicturePopUpViewControllerDelegate : BottomPicturePopUpViewControllerDelegate?
    
    @IBAction func thePhotoLibraryButtonPressed(sender: AnyObject) {
        setImagePickerDelegate()
    }

    @IBAction func theCameraButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let extraHeight : CGFloat = 45
        contentSizeInPopup = CGSizeMake(self.view.bounds.width, thePhotoLibraryButton.frame.height + theCameraButton.frame.height + extraHeight)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BottomPicturePopUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func setImagePickerDelegate() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        imgPicker.allowsEditing = true
        self.presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)
    {
        if image != nil {
            //would like to resize the image, but it was creating bars around the image. Will have to analyze the resizeImage function
//            let resizedImage = image.resizeImage(profileImageSize!)
            bottomPicturePopUpViewControllerDelegate?.passImage(image)
            dismissCurrentViewController()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissCurrentViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
