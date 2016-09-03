//
//  EditProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/22/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import STPopup
import EZSwiftExtensions

class EditProfileViewController: UIViewController {
    
    let currentUser = User.currentUser()
    
    @IBAction func theAgeButtonTapped(sender: UIButton) {
        DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
                (birthday) -> Void in
                let calendar : NSCalendar = NSCalendar.currentCalendar()
                let now = NSDate()
                let ageComponents = calendar.components(.Year,
                                                        fromDate: birthday,
                                                        toDate: now,
                                                        options: [])
                sender.setTitle("\(ageComponents.year)", forState: .Normal)
                self.currentUser?.birthDate = birthday
                //saving birthdate in two places in database because it will make querying easier with tags.
                let tag = Tags()
                tag.birthDate = birthday
                tag.saveInBackground()
        }
    }
    
    @IBAction func theSaveButtonPressed(sender: UIBarButtonItem) {
//        currentUser?.fullName = theNameTextField.text
//        currentUser?.title = theTitleTextField.text
//        currentUser?.factOne = theFactOneTextField.text
//        currentUser?.factTwo = theFactTwoTextField.text
//        currentUser?.factThree = theFactThreeTextField.text
        currentUser?.saveInBackgroundWithBlock({ (success, error) in
            if success {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                print(error)
            }
        })
    }
    
    func imageTapped() {
        createBottomPicturePopUp()
    }
    
    func createBottomPicturePopUp() {
//        let storyboard = UIStoryboard(name: "PopUp", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.BottomPicturePopUpViewController.rawValue) as! BottomPicturePopUpViewController
//        vc.bottomPicturePopUpViewControllerDelegate = self
//        vc.profileImageSize = self.theProfileImageView.frame.size
//        let popup = STPopupController(rootViewController: vc)
//        popup.navigationBar.barTintColor = ChachaTeal
//        popup.navigationBar.tintColor = UIColor.whiteColor()
//        popup.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        popup.style = STPopupStyle.BottomSheet
//        popup.presentInViewController(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
//        theProfileImageView.userInteractionEnabled = true
//        theProfileImageView.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension EditProfileViewController: BottomPicturePopUpViewControllerDelegate {
    func passImage(image: UIImage) {
//        theProfileImageView.image = image
//        let file = PFFile(name: "profileImage.jpg",data: UIImageJPEGRepresentation(theProfileImageView.image!, 0.6)!)
//        currentUser!.profileImage = file
    }
}
