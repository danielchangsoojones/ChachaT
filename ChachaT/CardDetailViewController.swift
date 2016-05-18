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
    
    var editingProfileState = true
    
    var userOfTheCard: User?
    
    @IBAction func fullNameTextFieldEditingChanged(sender: AnyObject) {
        theFullNameTextField.invalidateIntrinsicContentSize()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGUI(editingProfileState)
        setupTapHandler()
    }
    
    func createDetailPopUp() {
        //look at STPopUp github for more info.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("UserDetailPopUpViewController")
        let popup = STPopupController(rootViewController: vc)
        popup.containerView.layer.cornerRadius = 10.0
        popup.navigationBar.barTintColor = ChachaTeal
        popup.navigationBar.tintColor = UIColor.whiteColor()
        popup.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        popup.presentInViewController(self)
    }
    
    func setGUI(editingProfileState: Bool) {
        self.view.layer.addSublayer(setBottomBlur())
        if editingProfileState{
            self.profileImage.backgroundColor = ChachaBombayGrey
            self.profileImage.image = UIImage(named: "camera-Colored")
            self.profileImage.contentMode = .Center
            self.theFullNameLabel.hidden = true
            theFullNameTextField.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSForegroundColorAttributeName: ChachaTeal])
            theTitleLabel.hidden = true
        } else {
            
        }
    }
    
    private func setupTapHandler() {
        theProfileImageButtonOverlay.tapped { _ in
            self.imageTapped()
        }
        
        theAgeLabel.tapped { _ in
            DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
                (birthday) -> Void in
                let calendar : NSCalendar = NSCalendar.currentCalendar()
                let now = NSDate()
                let ageComponents = calendar.components(.Year,
                    fromDate: birthday,
                    toDate: now,
                    options: [])
                self.theAgeLabel.text = ", " + "\(ageComponents.year)"
            }
        }
        
        theFirstBulletText.tapped { (_) in
            self.createDetailPopUp()
        }
        

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
