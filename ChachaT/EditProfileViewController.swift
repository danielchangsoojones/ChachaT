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
import Timepiece

struct EditProfileConstants {
    static let numberOfBulletPoints : Int = 3
    static let bulletPointPlaceholder = "Something About You..."
    static let bulletPointTitle = "Bullet Point #"
    static let fullNameTitle = "Full Name"
    static let fullNamePlaceholder = "Enter Your Full Name..."
    static let schoolOrJobTitle = "School/Job Title"
    static let schoolOrJobPlaceholder = "Enter Your School or Job"
    static let ageTitle = "Age"
    static let agePlaceholder = "Tap to enter your birthday..."
}

class EditProfileViewController: UIViewController {
    @IBOutlet weak var photoLayoutView: PhotoEditingMasterLayoutView!
    @IBOutlet weak var theStackView: UIStackView!
    
    @IBOutlet weak var theBulletPointOneView: AboutView!
    @IBOutlet weak var theBulletPointTwoView: AboutView!
    @IBOutlet weak var theBulletPointThreeView: AboutView!
    
    var thePhotoNumberToChange: Int!
    var theEditedTextFieldArray : [UIView] = []
    //TODO: could refactor this to a function, so If I ever wanted to just add another bullet point, the code wouldn't need to be changed
    var theBulletPointWasEditedDictionary : [Int : Bool] = [:]
    let dataStore = EditProfileDataStore()
    let currentUser = User.currentUser()
    
    @IBAction func theSaveButtonPressed(sender: UIBarButtonItem) {
        saveTextIfEdited()
        resignFirstResponder()
        dataStore.saveEverything()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoLayoutView.delegate = self
        bulletPointsSetup()
        fullNameViewSetup()
        schoolOrJobViewSetup()
        ageViewSetup()
    }
    
    func bulletPointsSetup() {
        let titlePrefix = EditProfileConstants.bulletPointTitle
        for index in 1...EditProfileConstants.numberOfBulletPoints {
            let title = titlePrefix + "\(index)"
            let bulletPointView = AboutView(title: title, placeHolder: EditProfileConstants.bulletPointPlaceholder, bulletPointNumber: index, type: .GrowingTextView)
            theStackView.addArrangedSubview(bulletPointView)
            theBulletPointWasEditedDictionary[index] = false //set the values in the bulletPoint dictionary, all should start false because none have been edited yet
        }
    }
    
    func fullNameViewSetup() {
        let fullNameView = AboutView(title: EditProfileConstants.fullNameTitle, placeHolder: EditProfileConstants.fullNamePlaceholder, type: .NormalTextField)
        theStackView.addArrangedSubview(fullNameView)
    }
    
    func schoolOrJobViewSetup() {
        let schoolOrJobView = AboutView(title: EditProfileConstants.schoolOrJobTitle, placeHolder: EditProfileConstants.schoolOrJobPlaceholder, type: .NormalTextField)
        theStackView.addArrangedSubview(schoolOrJobView)
    }
    
    func ageViewSetup() {
        let ageView = AboutView(title: EditProfileConstants.ageTitle, placeHolder: EditProfileConstants.agePlaceholder, innerText: nil, action: {(sender: AboutView) in self.ageCellTapped(sender) }, type: .TappableCell)
        theStackView.addArrangedSubview(ageView)
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

//age extension
extension EditProfileViewController {
    func ageCellTapped(sender: AboutView) {
        DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (birthday) -> Void in
            let actualBirthday : NSDate = birthday - 1.day //for some reason, the birthday passed is one day ahead, even though it is entered correctly, so we need to subtract one
            let age = self.calculateAge(actualBirthday)
            sender.setInnerTitle("\(age)")
            self.dataStore.saveAge(actualBirthday)
        }
    }
    
    func calculateAge(birthday: NSDate) -> Int {
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let ageComponents = calendar.components(.Year,
                                                fromDate: birthday,
                                                toDate: now,
                                                options: [])
        return ageComponents.year
    }
    
    
    
}

extension EditProfileViewController {
    func saveTextIfEdited() {
        for subview in theStackView.arrangedSubviews {
            if let aboutView = subview as? AboutView where aboutView.wasEdited {
                //this view has been edited, so we need to save it
                if let text = aboutView.getCurrentText() {
                    switch aboutView.theType {
                    case .GrowingTextView:
                        if let bulletPointNumber = aboutView.getBulletPointNumber() {
                            dataStore.bulletPointWasEdited(text, bulletPointNumber: bulletPointNumber)
                        }
                    case .NormalTextField:
                        dataStore.textFieldWasEdited(text, title: aboutView.theTitleLabel.text!)
                    default:
                        break
                    }
                }
            }
        }
    }
}
