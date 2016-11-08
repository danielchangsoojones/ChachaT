//
//  EditProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/22/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import Timepiece
import EFTools

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
    static let tagSegueTitle = "Tags"
    static let tagSeguePlaceholder = "See your tags..."
}

class EditProfileViewController: UIViewController {
    @IBOutlet weak var photoLayoutView: PhotoEditingMasterLayoutView!
    @IBOutlet weak var theStackView: UIStackView!
    @IBOutlet weak var theScrollView: UIScrollView!
    var theSpinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, w: 100, h: 100))
    
    @IBOutlet weak var theBulletPointOneView: AboutView!
    @IBOutlet weak var theBulletPointTwoView: AboutView!
    @IBOutlet weak var theBulletPointThreeView: AboutView!
    
    @IBOutlet weak var theBottomConstraintToScrollView: NSLayoutConstraint!
    
    
    var thePhotoNumberToChange: Int!
    var dataStore : EditProfileDataStore!
    let currentUser = User.current()
    var theKeyboardIsShowing: Bool = false
    
    @IBAction func theSaveButtonPressed(_ sender: UIBarButtonItem) {
        showSpinner()
        saveTextIfEdited()
        resignFirstResponder()
        dataStore.saveEverything()
    }
    
    fileprivate func showSpinner() {
        if !theSpinner.isDescendant(of: self.view) {
            theSpinner.hidesWhenStopped = true
            theSpinner.activityIndicatorViewStyle = .whiteLarge
            theSpinner.color = CustomColors.JellyTeal
            self.view.addSubview(theSpinner)
            theSpinner.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        theSpinner.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.navigationController?.isNavigationBarHidden = false //when coming from the BackgroundAnimationVC, the nav bar is hidden, so we want to unhide
        
        photoLayoutView.delegate = self
        bulletPointsSetup()
        fullNameViewSetup()
        schoolOrJobViewSetup()
        ageViewSetup()
        tagPageSegueViewSetup()
        dataStoreSetup() //needs to happen after all the views have been added to the stackview, because we use the datastore to set any text on the views
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func dataStoreSetup() {
        dataStore = EditProfileDataStore(delegate: self)
        dataStore.loadEverything()
    }
    
    func bulletPointsSetup() {
        let titlePrefix = EditProfileConstants.bulletPointTitle
        for index in 1...EditProfileConstants.numberOfBulletPoints {
            let title = titlePrefix + "\(index)"
            let bulletPointView = AboutView(title: title, placeHolder: EditProfileConstants.bulletPointPlaceholder, bulletPointNumber: index, type: .growingTextView)
            bulletPointView.delegate = self
            theStackView.addArrangedSubview(bulletPointView)
        }
    }
    
    func fullNameViewSetup() {
        let fullNameView = AboutView(title: EditProfileConstants.fullNameTitle, placeHolder: EditProfileConstants.fullNamePlaceholder, type: .normalTextField)
        fullNameView.delegate = self
        theStackView.addArrangedSubview(fullNameView)
    }
    
    func schoolOrJobViewSetup() {
        let schoolOrJobView = AboutView(title: EditProfileConstants.schoolOrJobTitle, placeHolder: EditProfileConstants.schoolOrJobPlaceholder, type: .normalTextField)
        schoolOrJobView.delegate = self
        theStackView.addArrangedSubview(schoolOrJobView)
    }
    
    func ageViewSetup() {
        let ageView = AboutView(title: EditProfileConstants.ageTitle, placeHolder: EditProfileConstants.agePlaceholder, innerText: nil, action: { (sender) in
            self.ageCellTapped(sender)
            }, type: .tappableCell)
        theStackView.addArrangedSubview(ageView)
    }
    
    func tagPageSegueViewSetup() {
        let tagSegueView = AboutView(title: EditProfileConstants.tagSegueTitle, placeHolder: EditProfileConstants.tagSeguePlaceholder, innerText: nil, action: { (sender) in
            self.performSegueWithIdentifier(.EditProfileToAddingTagsSegue, sender: nil)
            }, type: .segueCell)
        theStackView.addArrangedSubview(tagSegueView)
    }
    
    func findAboutView(title: String) -> AboutView? {
        for subview in theStackView.arrangedSubviews {
            if let aboutView = subview as? AboutView, aboutView.getTitle() == title {
                return aboutView
            }
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension EditProfileViewController: AboutViewDelegate {
    func jumpToScrollViewPosition(yPosition: CGFloat) {
        theScrollView.setContentOffset(CGPoint(x: theScrollView.contentOffset.x, y: yPosition), animated: true)
    }
    
    func incrementScrollViewYPosition(by heightChange: CGFloat) {
        let contentYOffset = theScrollView.contentOffset.y + heightChange
        theScrollView.setContentOffset(CGPoint(x: theScrollView.contentOffset.x, y: contentYOffset), animated: true)
    }
}

extension EditProfileViewController: PhotoEditingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func photoPressed(_ photoNumber: Int, imageSize: CGSize, isPhotoWithImage: Bool) {
        thePhotoNumberToChange = photoNumber
        showPhotoChoices(isReplacingPhoto: isPhotoWithImage)
    }
    
    fileprivate func showPhotoChoices(isReplacingPhoto: Bool) {
        resignFirstResponder()
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if isReplacingPhoto {
            alert = showReplacePhotoChoices(alert: alert)
        } else {
            //clicked on a photo box that has never been edited
            alert = showNewPhotoChoices(alert: alert)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    fileprivate func showReplacePhotoChoices(alert: UIAlertController) -> UIAlertController {
        let replaceAction = UIAlertAction(title: "Replace Photo", style: .default) { (alertAction: UIAlertAction) in
            self.showPhotoChoices(isReplacingPhoto: false)
        }
        
        let deleteAction = UIAlertAction(title: "Delete Photo", style: .default) { (alertAction: UIAlertAction) in
            self.photoLayoutView.deleteImage(photoNumber: self.thePhotoNumberToChange)
            self.dataStore.deleteImage(photoNumber: self.thePhotoNumberToChange)
        }
        
        alert.addAction(replaceAction)
        alert.addAction(deleteAction)
        return alert
    }
    
    fileprivate func showNewPhotoChoices(alert: UIAlertController) -> UIAlertController {
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (alertAction: UIAlertAction) in
            _ = Camera.shouldStartPhotoLibrary(target: self, canEdit: false)
        }
        
        let facebookAction = UIAlertAction(title: "From Facebook", style: .default) { (alertAction: UIAlertAction) in
           self.showFacebookImagePicker()
        }
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (alertAction: UIAlertAction) in
            _ = Camera.shouldStartCamera(target: self, canEdit: false, frontFacing: true)
        }
        
        alert.addAction(photoLibraryAction)
        alert.addAction(facebookAction)
        alert.addAction(cameraAction)

        return alert
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        imageWasPicked(image: image, picker: picker)
    }
    
    func imageWasPicked(image: UIImage?, picker: UIViewController) {
        //would like to resize the image, but it was creating bars around the image. Will have to analyze the resizeImage function
        //            let resizedImage = image.resizeImage(profileImageSize!)
        if let image = image {
            photoLayoutView.setNewImage(image, photoNumber: thePhotoNumberToChange)
            dataStore.saveProfileImage(image, photoNumber: thePhotoNumberToChange)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

//age extension
extension EditProfileViewController {
    func ageCellTapped(_ sender: AboutView) {
        DatePickerDialog().show("Your Birthday!", defaultDate: User.current()!.birthDate ?? Date(),  datePickerMode: .date) {
            (birthday) -> Void in
            let age = User.current()!.calculateAge(birthday: birthday)
            sender.setInnerTitle("\(age)")
            self.dataStore.saveAge(birthday)
        }
    }
}

extension EditProfileViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case EditProfileToAddingTagsSegue
    }
}

extension EditProfileViewController : EditProfileDataStoreDelegate {
    func loadBulletPoint(_ text: String, num: Int) {
        let prefix = EditProfileConstants.bulletPointTitle
        let suffix = num.toString
        let title = prefix + suffix
        loadText(text, title: title)
    }
    
    func loadProfileImage(_ file: AnyObject, num: Int) {
        photoLayoutView.setNewImageFromFile(file, photoNumber: num)
    }
    
    func loadText(_ text: String, title: String) {
        let aboutView = findAboutView(title: title)
        aboutView?.setCurrentText(text)
    }
    
    func saveTextIfEdited() {
        for subview in theStackView.arrangedSubviews {
            if let aboutView = subview as? AboutView , aboutView.wasEdited {
                //this view has been edited, so we need to save it
                if let text = aboutView.getCurrentText() {
                    switch aboutView.theType {
                    case .growingTextView:
                        if let bulletPointNumber = aboutView.getBulletPointNumber() {
                            dataStore.bulletPointWasEdited(text, bulletPointNumber: bulletPointNumber)
                        }
                    case .normalTextField:
                        dataStore.textFieldWasEdited(text, title: aboutView.theTitleLabel.text!)
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func finishedSaving() {
        theSpinner.stopAnimating()
        self.view.endEditing(true)
    }
}

//the keyboard extension
extension EditProfileViewController {
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.theScrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.theScrollView.contentInset = contentInset
    }
}
