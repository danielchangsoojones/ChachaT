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
import SCLAlertView

public enum QuestionDetailState {
    case editingMode
    case profileViewOnlyMode
    case otherUserProfileViewOnlyMode
}

class CardDetailViewController: UIViewController {
    fileprivate struct CardDetailConstants {
        static let backButtonCornerRadius: CGFloat = 10
    }
    
    
    @IBOutlet weak var theBulletPointsStackView: UIStackView!
    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var theProfileImageButtonOverlay: UIButton!
    @IBOutlet weak var theFullNameLabel: UILabel!
    @IBOutlet weak var theAgeLabel: UILabel!
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theBackButton: UIButton!
    @IBOutlet weak var theSavingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var theCardUserTagListView: ChachaChoicesTagListView!
    
    //Constraints
    @IBOutlet weak var theBackButtonLeadingConstraint: NSLayoutConstraint!
    
    var userOfTheCard: User? = User.current() //just setting a defualt, should be passed through dependency injection
    var dataStore: CardDetailDataStore!
    
    var isViewingOwnProfile: Bool = false {
        didSet {
            createEditProfileButton()
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func createEditProfileButton() {
        let editProfileButton = UIButton()
        editProfileButton.setTitle("Edit Profile", for: .normal)
        editProfileButton.backgroundColor = theBackButton.backgroundColor
        editProfileButton.setCornerRadius = CardDetailConstants.backButtonCornerRadius
        self.view.addSubview(editProfileButton)
        editProfileButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(theBackButton)
            make.trailing.equalTo(self.view).inset(theBackButtonLeadingConstraint.constant)
        }
    }
    
    
    @IBAction func reportAbuseButtonPressed(_ sender: AnyObject) {
        let alertView = SCLAlertView()
        _ = alertView.addButton("Block User", action: {
            let responder = SCLAlertViewResponder(alertview: alertView)
            responder.close()
        })
        _ = alertView.showError("Report Abuse", subTitle: "The profile has been reported, and moderators will be examining the profile shortly.", closeButtonTitle: "Cancel")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataStoreSetup()
        setNormalGUI()
        setupTapHandler()
    }
    
    func dataStoreSetup() {
        dataStore = CardDetailDataStore(delegate: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setNormalGUI() {
        dataStore.loadTags(user: userOfTheCard!)
        self.view.layer.addSublayer(setBottomBlur(blurHeight: 100, color: CustomColors.JellyTeal))
        theBackButton.layer.cornerRadius = CardDetailConstants.backButtonCornerRadius
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
            theProfileImageButtonOverlay.setTitle("No Picture", for: UIControlState())
            theProfileImageButtonOverlay.titleLabel?.textAlignment = .center
        }
    }
    
    func bulletPointSetup(_ text: String, width: CGFloat) {
        let bulletPointView = BulletPointView(text: text, width: width)
        theBulletPointsStackView.addArrangedSubview(bulletPointView)
    }
    
    fileprivate func setupTapHandler() {
        _ = theProfileImageButtonOverlay.tapped { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }

}

extension CardDetailViewController: MagicMoveable {
    
    var isMagic: Bool {
        return true
    }
    
    var duration: TimeInterval {
        return 1.0
    }
    
    var spring: CGFloat {
        return 1.0
    }
    
    var magicViews: [UIView] {
        return [profileImage]
    }
}
