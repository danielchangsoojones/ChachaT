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


class CardDetailViewController: CardDetailSuperViewController {
    
    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var theFirstBulletText: UILabel!
    @IBOutlet weak var theQuestionButtonOne: UIButton!
    @IBOutlet weak var theQuestionButtonTwo: UIButton!
    @IBOutlet weak var theCustomQuestionButton: UIButton!
    @IBOutlet weak var theProfileImageButtonOverlay: UIButton!
    @IBOutlet weak var theFullNameTextField: UITextField!
    @IBOutlet weak var theFullNameLabel: UILabel!
    @IBOutlet weak var theAgeLabel: UILabel!
    
    var editingProfileState = true
    
    var userOfTheCard: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGUI(editingProfileState)
        setupTapHandler()
    }
    
    func setGUI(editingProfileState: Bool) {
        if editingProfileState{
            self.profileImage.backgroundColor = ChachaBombayGrey
            self.profileImage.image = UIImage(named: "camera-Colored")
            self.profileImage.contentMode = .Center
            self.theFullNameLabel.hidden = true
            theFullNameTextField.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSForegroundColorAttributeName: ChachaTeal])
        } else {
            
        }
    }
    
    private func setupTapHandler() {
        theProfileImageButtonOverlay.tapped { _ in
            self.imageTapped()
        }
        theAgeLabel.tapped { (_) in
            //have a date delegate pop up
            DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
                (date) -> Void in
            }
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
