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
import EFTools

public enum QuestionDetailState {
    case EditingMode
    case ProfileViewOnlyMode
    case OtherUserProfileViewOnlyMode
}

class CardDetailViewController: UIViewController {
    
    
    @IBOutlet weak var theBulletPointsStackView: UIStackView!
    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var theProfileImageButtonOverlay: UIButton!
    @IBOutlet weak var theFullNameLabel: UILabel!
    @IBOutlet weak var theAgeLabel: UILabel!
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theBackButton: UIButton!
    @IBOutlet weak var theSavingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var theUserOfCardTagListView: TagListView!
    
    var userOfTheCard: User? = User.currentUser()
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    @IBAction func reportAbuseButtonPressed(sender: AnyObject) {
        let alert = Alert(closeButtonHidden: false)
        alert.addButton("Block User") { 
            alert.closeAlert()
        }
       alert.createAlert("Report Abuse", subtitle: "The profile has been reported, and moderators will be examining the profile shortly.", closeButtonTitle: "Okay", type: .Error)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNormalGUI()
        setupTapHandler()
    }
    
    func setNormalGUI() {
        self.view.layer.addSublayer(setBottomBlur())
        theBackButton.layer.cornerRadius = 10
        if let fullName = userOfTheCard?.fullName {
            theFullNameLabel.text = fullName
        }
        if let title = userOfTheCard?.title {
            theTitleLabel.text = title
        }
        if let age = userOfTheCard?.age {
            theAgeLabel.text = ", " + "\(age)"
        }
        let bulletPointViewWidth = theBulletPointsStackView.frame.width
        if let factOne = userOfTheCard?.bulletPoint1 {
            bulletPointSetup(factOne, width: bulletPointViewWidth)
        }
        if let factTwo = userOfTheCard?.bulletPoint2 {
            bulletPointSetup(factTwo, width: bulletPointViewWidth)
        }
        if let factThree = userOfTheCard?.bulletPoint3 {
            bulletPointSetup(factThree, width: bulletPointViewWidth)
        }
        if let profileImage = userOfTheCard?.profileImage {
            self.profileImage.file = profileImage
            self.profileImage.loadInBackground()
        } else {
            profileImage.backgroundColor = ChachaBombayGrey
            theProfileImageButtonOverlay.setTitle("No Picture", forState: .Normal)
            theProfileImageButtonOverlay.titleLabel?.textAlignment = .Center
        }
    }
    
    func bulletPointSetup(text: String, width: CGFloat) {
        let bulletPointView = BulletPointView(text: text, width: width)
        theBulletPointsStackView.addArrangedSubview(bulletPointView)
    }
    
    private func setupTapHandler() {
        theProfileImageButtonOverlay.tapped { _ in
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

extension CardDetailViewController: MagicMoveable {
    
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
