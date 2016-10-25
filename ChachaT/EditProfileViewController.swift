//
//  EditProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/22/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import STPopup
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
    static let heightTitle = "Height"
    static let heightPlaceholder = "Tap to enter your height..."
    static let tagSegueTitle = "Tags"
    static let tagSeguePlaceholder = "See your tags..."
}

class EditProfileViewController: UIViewController {
    @IBOutlet weak var photoLayoutView: PhotoEditingMasterLayoutView!
    @IBOutlet weak var theStackView: UIStackView!
    @IBOutlet weak var theScrollView: UIScrollView!
    
    @IBOutlet weak var theBulletPointOneView: AboutView!
    @IBOutlet weak var theBulletPointTwoView: AboutView!
    @IBOutlet weak var theBulletPointThreeView: AboutView!
    
    @IBOutlet weak var theBottomConstraintToScrollView: NSLayoutConstraint!
    
    
    var thePhotoNumberToChange: Int!
    var theEditedTextFieldArray : [UIView] = []
    //TODO: could refactor this to a function, so If I ever wanted to just add another bullet point, the code wouldn't need to be changed
    var theBulletPointWasEditedDictionary : [Int : Bool] = [:]
    var dataStore : EditProfileDataStore!
    let currentUser = User.current()
    var theKeyboardIsShowing: Bool = false
    
    @IBAction func theSaveButtonPressed(_ sender: UIBarButtonItem) {
        saveTextIfEdited()
        resignFirstResponder()
        dataStore.saveEverything()
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
        heightViewSetup()
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
            theBulletPointWasEditedDictionary[index] = false //set the values in the bulletPoint dictionary, all should start false because none have been edited yet
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
    
    func heightViewSetup() {
        let heightView = AboutView(title: EditProfileConstants.heightTitle, placeHolder: EditProfileConstants.heightPlaceholder, innerText: nil, action: { (sender) in
            self.performSegue(withIdentifier: SegueIdentifier.EditProfileToHeightPickerSegue.rawValue, sender: nil)
            }, type: .tappableCell)
        theStackView.addArrangedSubview(heightView)
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
}

extension EditProfileViewController: PhotoEditingDelegate {
    func photoPressed(_ photoNumber: Int, imageSize: CGSize) {
        thePhotoNumberToChange = photoNumber
        createBottomPicturePopUp(imageSize)
    }
    
    func createBottomPicturePopUp(_ imageSize: CGSize) {
        let storyboard = UIStoryboard(name: "PopUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifiers.BottomPicturePopUpViewController.rawValue) as! BottomPicturePopUpViewController
        vc.bottomPicturePopUpViewControllerDelegate = self
        vc.profileImageSize = imageSize
        let popup = STPopupController(rootViewController: vc)
        popup?.navigationBar.barTintColor = ChachaTeal
        popup?.navigationBar.tintColor = UIColor.white
        popup?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        popup?.style = STPopupStyle.bottomSheet
        popup?.present(in: self)
    }
}

extension EditProfileViewController: BottomPicturePopUpViewControllerDelegate {
    func passImage(_ image: UIImage) {
        photoLayoutView.setNewImage(image, photoNumber: thePhotoNumberToChange)
        dataStore.saveProfileImage(image, photoNumber: thePhotoNumberToChange)
    }
}

//age extension
extension EditProfileViewController {
    func ageCellTapped(_ sender: AboutView) {
        DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (birthday) -> Void in
            let actualBirthday : Date = birthday - 1.day //for some reason, the birthday passed is one day ahead, even though it is entered correctly, so we need to subtract one
            let age = self.calculateAge(actualBirthday)
            sender.setInnerTitle("\(age)")
            self.dataStore.saveAge(actualBirthday)
        }
    }
    
    func calculateAge(_ birthday: Date) -> Int {
        let calendar : Calendar = Calendar.current
        let now = Date()
        let ageComponents = (calendar as NSCalendar).components(.year,
                                                from: birthday,
                                                to: now,
                                                options: [])
        return ageComponents.year!
    }
}

extension EditProfileViewController: HeightPickerDelegate {
    func passHeight(height: String, totalInches: Int) {
        if let heightView = findAboutView(title: EditProfileConstants.heightTitle) {
            heightView.setInnerTitle(height)
            dataStore.saveHeight(height: totalInches)
        }
    }
}

extension EditProfileViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case EditProfileToAddingTagsSegue
        case EditProfileToHeightPickerSegue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case .EditProfileToHeightPickerSegue:
            let destinationVC = segue.destination as! HeightPickerViewController
            destinationVC.delegate = self
        default:
            break
        }
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
