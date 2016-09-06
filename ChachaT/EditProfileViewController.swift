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
    
    @IBOutlet weak var photoLayoutView: PhotoEditingMasterLayoutView!
    @IBOutlet weak var theStackView: UIStackView!
    
    @IBOutlet weak var theBulletPointOneView: AboutView!
    @IBOutlet weak var theBulletPointTwoView: AboutView!
    @IBOutlet weak var theBulletPointThreeView: AboutView!
    
    var thePhotoNumberToChange: Int!
    //TODO: could refactor this to a function, so If I ever wanted to just add another bullet point, the code wouldn't need to be changed
    var theBulletPointWasEditedDictionary : [Int : Bool] = [1 : false , 2 : false, 3 : false]
    let dataStore = EditProfileDataStore()
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
        saveBulletPointsIfEdited()
        dataStore.saveEverything()
//        currentUser?.fullName = theNameTextField.text
//        currentUser?.title = theTitleTextField.text
//        currentUser?.factOne = theFactOneTextField.text
//        currentUser?.factTwo = theFactTwoTextField.text
//        currentUser?.factThree = theFactThreeTextField.text
//        currentUser?.saveInBackgroundWithBlock({ (success, error) in
//            if success {
//                self.navigationController?.popViewControllerAnimated(true)
//            } else {
//                print(error)
//            }
//        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoLayoutView.delegate = self
        bulletPointsSetup()
    }
    
    //TODO: refactor this by going through subviews, so we don't have to change code if we added another one.
    func bulletPointsSetup() {
        theBulletPointOneView.setImportantInformation(self, bulletPointNumber: 1)
        theBulletPointTwoView.setImportantInformation(self, bulletPointNumber: 2)
        theBulletPointThreeView.setImportantInformation(self, bulletPointNumber: 3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension EditProfileViewController: PhotoEditingDelegate {
    func photoPressed(photoNumber: Int, imageSize: CGSize) {
        thePhotoNumberToChange = photoNumber
        createBottomPicturePopUp(imageSize)
    }
    
    func createBottomPicturePopUp(imageSize: CGSize) {
        let storyboard = UIStoryboard(name: "PopUp", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.BottomPicturePopUpViewController.rawValue) as! BottomPicturePopUpViewController
        vc.bottomPicturePopUpViewControllerDelegate = self
        vc.profileImageSize = imageSize
        let popup = STPopupController(rootViewController: vc)
        popup.navigationBar.barTintColor = ChachaTeal
        popup.navigationBar.tintColor = UIColor.whiteColor()
        popup.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        popup.style = STPopupStyle.BottomSheet
        popup.presentInViewController(self)
    }
}

extension EditProfileViewController: BottomPicturePopUpViewControllerDelegate {
    func passImage(image: UIImage) {
        photoLayoutView.setNewImage(image, photoNumber: thePhotoNumberToChange)
        dataStore.saveProfileImage(image, photoNumber: thePhotoNumberToChange)
    }
}

extension EditProfileViewController: AboutViewDelegate {
    func textHasChanged(bulletPointNumber: Int) {
        theBulletPointWasEditedDictionary[bulletPointNumber] = true
        print("the text has changed")
    }
    
    func saveBulletPointsIfEdited() {
        for (num, wasEdited) in theBulletPointWasEditedDictionary where wasEdited {
            if let aboutView = findAboutView(num) {
                dataStore.bulletPointWasEdited(aboutView.getCurrentText(), bulletPointNumber: num)
            }
        }
    }
    
    func findAboutView(num: Int) -> AboutView? {
        for subview in self.theStackView.arrangedSubviews {
            if let aboutView = subview as? AboutView where aboutView.theBulletPointNumber == num {
                return aboutView
            }
        }
        return nil //shouldn't reach here
    }
}
