//
//  SecondVC.swift
//  MagicMove
//
//  Created by Patrick Reynolds on 1/24/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import STPopup

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var theFirstBulletText: UILabel!
    @IBOutlet weak var theQuestionButtonOne: UIButton!
    @IBOutlet weak var theQuestionButtonTwo: UIButton!
    @IBOutlet weak var theCustomQuestionButton: UIButton!
    @IBOutlet weak var theProfileImageButtonOverlay: UIButton!
    @IBOutlet weak var theFullNameTextField: UITextField!
    @IBOutlet weak var theFullNameLabel: UILabel!
    @IBOutlet weak var theAgeLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theSecondBulletText: UILabel!
    @IBOutlet weak var theThirdBulletText: UILabel!
    @IBOutlet weak var editOrBackOrSaveButton: UIButton!
    @IBOutlet weak var theSavingSpinner: UIActivityIndicatorView!
    
    enum FloatingButtonState {
        case Save
        case Edit
        case DismissViewController
    }
    
    var fullNameTextFieldDidChange = false
    var titleTextFieldDidChange = false
    //need to set this to editing if I want to have profile that is editable
    var floatingButtonState : FloatingButtonState = .DismissViewController
    
    var userOfTheCard: User?
    
    @IBAction func editOrBackOrSavePressed(sender: AnyObject) {
        switch floatingButtonState {
        case .Save:
            //the user is editing right now, and will hit the save button to save their work
            if fullNameTextFieldDidChange {
                let fullNameText = theFullNameTextField.text
                userOfTheCard?.fullName = fullNameText
                userOfTheCard?.lowercaseFullName = fullNameText?.lowercaseString
            }
            if titleTextFieldDidChange {
                userOfTheCard?.title = titleTextField.text
            }
            editOrBackOrSaveButton.setTitle("", forState: .Normal)
            theSavingSpinner.hidden = false
            theSavingSpinner.startAnimating()
            userOfTheCard?.saveInBackgroundWithBlock({ (success, error) in
                if success {
                    self.theSavingSpinner.stopAnimating()
                    self.theSavingSpinner.hidden = true
                    self.editOrBackOrSaveButton.setTitle("Edit", forState: .Normal)
                } else {
                    let _ = Alert(title: "Problem Saving Profile", subtitle: "Please try to save again", closeButtonTitle: "Okay", closeButtonHidden: false, type: .Error)
                }
            })
            floatingButtonState = .Edit
        case .Edit:
            //the user is on the profile page, but not currently wanting to edit anything. Only looking.
                editOrBackOrSaveButton.setTitle("Save", forState: .Normal)
                floatingButtonState = .Save
                setEditingGUI()
        case .DismissViewController:
            //the user is on the normal card view and looking at another user. This just dismisses the detail view back to the card stack
            imageTapped()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGUI()
        setupTapHandler()
    }
    
    func createDetailPopUp(factNumber: Fact) {
        //look at STPopUp github for more info.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("UserDetailPopUpViewController") as! UserDetailPopUpViewController
        vc.delegate = self
        vc.factNumber = factNumber
        switch factNumber {
        case .FactOne:
            vc.factDescriptionText = theFirstBulletText.text
        case .FactTwo:
            vc.factDescriptionText = theSecondBulletText.text
        case .FactThree:
            vc.factDescriptionText = theThirdBulletText.text
        }
        let popup = STPopupController(rootViewController: vc)
        popup.containerView.layer.cornerRadius = 10.0
        popup.navigationBar.barTintColor = ChachaTeal
        popup.navigationBar.tintColor = UIColor.whiteColor()
        popup.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        popup.presentInViewController(self)
    }
    
    func setGUI() {
        self.view.layer.addSublayer(setBottomBlur())
        if let fullName = userOfTheCard?.fullName {
            theFullNameLabel.text = fullName
        }
        if let title = userOfTheCard?.title {
            theTitleLabel.text = title
        }
        
        if floatingButtonState == .Edit {
            editOrBackOrSaveButton.setTitle("edit", forState: .Normal)
        }
    }
    
    func setEditingGUI() {
        //to see if any of the textfields have actually been changed.
        theFullNameTextField.addTarget(self, action: #selector(CardDetailViewController.fullNameTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        titleTextField.addTarget(self, action: #selector(CardDetailViewController.titleTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        if let fullName = userOfTheCard?.fullName {
            theFullNameTextField.text = fullName
        }
        if let age = userOfTheCard?.calculateBirthDate() {
            theAgeLabel.text = ", " + "\(age)"
        }
        if let title = userOfTheCard?.title {
            titleTextField.text = title
        }
        self.profileImage.backgroundColor = ChachaBombayGrey
        self.profileImage.image = UIImage(named: "camera-Colored")
        self.profileImage.contentMode = .Center
        self.theFullNameLabel.hidden = true
        self.theFullNameTextField.hidden = false
        self.titleTextField.hidden = false
        theFullNameTextField.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSForegroundColorAttributeName: ChachaTeal])
        theTitleLabel.hidden = true
        theCustomQuestionButton.setTitle("Find Friends", forState: .Normal)
    }
    
    func fullNameTextFieldDidChange(textField: UITextField) {
        fullNameTextFieldDidChange = true
    }
    
    func titleTextFieldDidChange(textField: UITextField) {
        titleTextFieldDidChange = true
    }
    
    
    
    private func setupTapHandler() {
        theProfileImageButtonOverlay.tapped { _ in
            self.imageTapped()
        }
        
        theAgeLabel.tapped { _ in
            if self.floatingButtonState == .Save {
                DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
                    (birthday) -> Void in
                    let calendar : NSCalendar = NSCalendar.currentCalendar()
                    let now = NSDate()
                    let ageComponents = calendar.components(.Year,
                        fromDate: birthday,
                        toDate: now,
                        options: [])
                    self.theAgeLabel.text = ", " + "\(ageComponents.year)"
                    self.userOfTheCard?.birthDate = birthday
                    self.userOfTheCard?.saveInBackground()
                }
            }
        }
        
        if self.floatingButtonState == .Save {
            theFirstBulletText.tapped { (_) in
                self.createDetailPopUp(Fact.FactOne)
            }
            
            theSecondBulletText.tapped { (_) in
                self.createDetailPopUp(Fact.FactTwo)
            }
            
            theThirdBulletText.tapped { (_) in
                self.createDetailPopUp(Fact.FactThree)
            }
        }

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}


protocol PopUpViewControllerDelegate{
    func passFactDescription(text: String, fact: Fact)
}

extension CardDetailViewController: PopUpViewControllerDelegate {
    func passFactDescription(text: String, fact: Fact) {
        switch fact {
        case .FactOne: theFirstBulletText.text = text
        case .FactTwo: theSecondBulletText.text = text
        case .FactThree: theThirdBulletText.text = text
        }
    }
}

extension CardDetailViewController: MagicMoveable {
    func imageTapped() {
        let backgroundAnimationVC = UIStoryboard(name: Storyboards.Main.storyboard, bundle: nil).instantiateViewControllerWithIdentifier(String(BackgroundAnimationViewController)) as! BackgroundAnimationViewController
        
        //not animating right now because it was fucking things up.
        presentViewControllerMagically(self, to: backgroundAnimationVC, animated: false, duration: duration, spring: spring)
    }
    
    var isMagic: Bool {
        return true
    }
    
    var duration: NSTimeInterval {
        return 1.0
    }
    
    var spring: CGFloat {
        return 1.0
    }
    
    var magicViews: [UIView] {
        return [profileImage]
    }
}
