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
import EFTools
import SCLAlertView
import TGLParallaxCarousel
import EZSwiftExtensions

class CardDetailViewController: UIViewController {
    fileprivate struct CardDetailConstants {
        static let backButtonCornerRadius: CGFloat = 10
        static let backButtonBackgroundColor: UIColor = UIColor.black
        static let backButtonAlpha: CGFloat = 0.5
    }
    
    @IBOutlet weak var theBulletPointsStackView: UIStackView!
    @IBOutlet weak var theBackButton: UIButton!
    @IBOutlet weak var theCardUserTagListView: ChachaChoicesTagListView!
    @IBOutlet weak var theDescriptionDetailView: DescriptionDetailView!
    @IBOutlet weak var theProfileImageHolderView: UIView!
    var theProfileImageCarouselView: TGLParallaxCarousel!
    
    //Constraints
    @IBOutlet weak var theBackButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var theBackButtonTopConstraint: NSLayoutConstraint!
    
    var userOfTheCard: User? = User.current() //just setting a defualt, should be passed through dependency injection
    //TODO: we really only need to take in a swipe to the cardDetailPage, and then we can set the userOfTheCard from there
    var swipe: Swipe? {
        didSet {
            addCardMessageChildVC()
        }
    }
    var dataStore: CardDetailDataStore!
    
    var delegate: BottomButtonsDelegate?
    
    var isViewingOwnProfile: Bool = false {
        didSet {
            createEditProfileButton()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        if let navController = navigationController {
            //for when we presented this VC in nav controller
            _ = navController.popViewController(animated: true)
        } else {
            //for when we presented this vc modally
            self.dismiss(animated: false, completion: nil)
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
        profileImageCarouselSetup()
    }
    
    func addCardMessageChildVC() {
        let childVC = NewCardMessageViewController()
        childVC.swipe = swipe
        addAsChildViewController(childVC, toView: self.view)
        theBackButtonTopConstraint.constant = childVC.view.frame.height + 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isViewingOwnProfile {
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isViewingOwnProfile {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    func dataStoreSetup() {
        dataStore = CardDetailDataStore(delegate: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setNormalGUI() {
        dataStore.loadTags(user: userOfTheCard!)
        theBackButton.layer.cornerRadius = CardDetailConstants.backButtonCornerRadius
        theDescriptionDetailView.userOfTheCard = userOfTheCard
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
        setBottomButtons()
    }
    
    func bulletPointSetup(_ text: String, width: CGFloat) {
        let bulletPointView = BulletPointView(text: text, width: width)
        theBulletPointsStackView.addArrangedSubview(bulletPointView)
    }
    
    func setBottomButtons() {
        //setting the height to the nopeButton's height because that is the height of the view
        if delegate != nil {
            self.view.layer.addSublayer(setBottomBlur(blurHeight: ez.screenHeight * 0.23, color: CustomColors.JellyTeal))
            let bottomButtonsView = BottomButtonsView(addMessageButton: true, delegate: self)
            self.view.addSubview(bottomButtonsView)
            bottomButtonsView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
            }
        }
    }
}

extension CardDetailViewController: TGLParallaxCarouselDelegate {
    func profileImageCarouselSetup() {
        theProfileImageCarouselView = TGLParallaxCarousel()
        theProfileImageHolderView.addSubview(theProfileImageCarouselView)
        theProfileImageCarouselView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        theProfileImageCarouselView.delegate = self
        theProfileImageCarouselView.currentPageIndicatorColor = CustomColors.JellyTeal
    }
    
    func numberOfItemsInCarouselView(_ carouselView: TGLParallaxCarousel) -> Int {
        return userOfTheCard?.nonNilProfileImages.count ?? 0
    }
    
    func carouselView(_ carouselView: TGLParallaxCarousel, itemForRowAtIndex index: Int) -> TGLParallaxCarouselItem {
        let slideView = CarouselSlideView(file: userOfTheCard?.nonNilProfileImages[index], frame: carouselView.frame)
        return slideView
    }
    
    //TODO: will need to make a tap handler or something because sliding is really hard without tapping, check how it fairs on a real device, might just suck for the mac simulator
    func carouselView(_ carouselView: TGLParallaxCarousel, didSelectItemAtIndex index: Int) {}
    
    func carouselView(_ carouselView: TGLParallaxCarousel, willDisplayItem item: TGLParallaxCarouselItem, forIndex index: Int) {}
}

//Edit Profile Extension
extension CardDetailViewController {
    fileprivate func createEditProfileButton() {
        let editProfileButton = UIButton()
        editProfileButton.setTitle("Edit Profile", for: .normal)
        editProfileButton.addTarget(self, action: #selector(editProfileButtonPressed(sender:)), for: .touchUpInside)
        editProfileButton.backgroundColor = CardDetailConstants.backButtonBackgroundColor
        editProfileButton.alpha = CardDetailConstants.backButtonAlpha
        editProfileButton.layer.cornerRadius = CardDetailConstants.backButtonCornerRadius
        self.view.addSubview(editProfileButton)
        editProfileButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(theBackButton)
            make.trailing.equalTo(self.view).inset(theBackButtonLeadingConstraint.constant)
        }
    }
    
    func editProfileButtonPressed(sender: UIButton!) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
}

extension CardDetailViewController: BottomButtonsDelegate {
    func nopeButtonPressed() {
        dismiss(animated: false, completion: {
            self.delegate?.nopeButtonPressed()
        })
    }
    
    func approveButtonPressed() {
        dismiss(animated: false, completion: {
            self.delegate?.approveButtonPressed()
        })
    }
    
    func messageButtonPressed() {
        performSegue(withIdentifier: SegueIdentifier.CardDetailToSendMessageSegue.rawValue, sender: nil)
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
        //TODO: not sure how good this animation is looking
        return [theProfileImageCarouselView]
    }
}

extension CardDetailViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case CardDetailToSendMessageSegue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case .CardDetailToSendMessageSegue:
            let destinationVC = segue.destination as! CardSendMessageViewController
            destinationVC.userToSend = userOfTheCard
        }
    }
}
