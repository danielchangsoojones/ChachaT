//
//  BackgroundAnimationViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/10/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import pop
import Koloda
import AVFoundation
import Parse
import EFTools
import ParseUI
import Ripple
import SnapKit
import Timepiece

private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0
var wooshSound = URL(fileURLWithPath: Bundle.main.path(forResource: "woosh", ofType: "wav")!)
var audioPlayerWoosh = AVAudioPlayer()
private let numberOfCards : UInt = 5

//go to Yalantis/Koloda github to see examples/more documentation on what Koloda is. 
class BackgroundAnimationViewController: UIViewController {
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var theMagicMovePlaceholderImage: PFImageView!
    @IBOutlet weak var theChachaLoadingImage: UIImageView!
    @IBOutlet weak var theBackgroundColorView: UIView!
    @IBOutlet weak var theApproveButton: UIButton!
    @IBOutlet weak var theSkipButton: UIButton!
    @IBOutlet weak var theMessageButton: UIButton!
    @IBOutlet weak var theProfileButton: UIButton!
    @IBOutlet weak var theBottomButtonStackView: UIStackView!
    var leftNavigationButton: UIBarButtonItem?
    var rightNavigationButton: UIBarButtonItem?
    
    //constraint outlets
    @IBOutlet weak var theStackViewBottomConstraint: NSLayoutConstraint!

    var userArray = [User]()
    fileprivate var dataStore : BackgroundAnimationDataStore = BackgroundAnimationDataStore()
    var rippleHasNotBeenStarted = true
    
    let locationManager = CLLocationManager()
    
    @IBAction func skipCard(_ sender: AnyObject) {
        kolodaView.swipe(.Left)
    }
    
    @IBAction func approveCard(_ sender: UIButton) {
        kolodaView.swipe(.Right)
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundGradientSetup()
        setKolodaAttributes()
        setFakeNavigationBarView()
        if userArray.isEmpty {
            //if user array is empty, then that means we should load users
            //if it is not empty, that means the userArray was passed from the search page, so don't load new users
            createUserArray()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true //created a fake nav bar, so want to hide the real nav bar whenever I come on the screen
        self.theMagicMovePlaceholderImage.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if rippleHasNotBeenStarted {
            //only want to have ripple appear once, if we leave th page via pageviewcontroller, the view appears again and would think to start a second ripple.
            //this makes it only appear the first run time.
            ripple(theChachaLoadingImage.center, view: theBackgroundColorView, color: CustomColors.JellyTeal.withAlphaComponent(0.5))
            rippleHasNotBeenStarted = false
        }
        //we have to set the kolodaView dataSource in viewDidAppear because there is a bug in the Koloda cocoapod. When you have data preset (like when we pass the user array from 8tracks). The koloda Card view doesn't show correctly, it is misplaced. So, we have to wait to load it in viewDidAppear, for it to load correctly, until the Koloda cocoapod is upgraded to fix this.
        kolodaView.dataSource = self
        kolodaView.reloadData()
        getUserLocation()
    }
    
    func backgroundGradientSetup() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        
        let color1 = UIColor.white.cgColor as CGColor
        let color2 = CustomColors.PeriwinkleGray.cgColor as CGColor
        
        gradientLayer.colors = [color1, color2]
        
        gradientLayer.locations = [0.5, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)

    }
    
    func playSoundInBG(_ theAudioPlayer:AVAudioPlayer) {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            theAudioPlayer.play()
        })
    }
    
    //Purpose: we created a fake navigation bar because we are turning off the normal navigation bar. Then, we use this view as a fake navigation bar that the user can't tell the difference. We need to do this because we need the view to grow to include the left side menu drop down menu. The normal nav bar shows the buttons, but they aren't clickable because they are outside the nav bars bounds. So, we need to make this view's frame grow, so the buttons become clickable.
    func setFakeNavigationBarView() {
        let fakeNavigationBarView = FakeNavigationBarView(navigationBarHeight: self.navigationController!.navigationBar.frame.height, delegate: self)
        self.view.addSubview(fakeNavigationBarView)
        fakeNavigationBarView.snp.makeConstraints { (make) in
            make.trailing.leading.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(self.navigationController!.navigationBar.frame.height + ImportantDimensions.StatusBarHeight)
        }
    }
}

extension BackgroundAnimationViewController: CLLocationManagerDelegate {
    func getUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        locationManager.requestLocation() //requests the location just once, no sense in constantly updating their location and draining their battery, when they are most likely in the same place. In the future, we will probably want to be updating there location.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            dataStore.saveCurrentUserLocation(location: currentLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//queries
extension BackgroundAnimationViewController {
    //TODO: move this into the data store
    func createUserArray() {
            //normal creating of the stack.
            let query = User.query()
            if let objectId = User.current()?.objectId {
                query?.whereKey("objectId", notEqualTo: objectId)
            }
            query?.findObjectsInBackground(block: { (objects, error) -> Void in
                if let users = objects as? [User] {
                    self.userArray = users
                    self.kolodaView.dataSource = self
                    self.kolodaView.reloadData()
                }
            })
    }
}

//MARK: KolodaViewDelegate
extension BackgroundAnimationViewController: KolodaViewDelegate, CustomKolodaViewDelegate {
    func setKolodaAttributes() {
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        //TODO: figure out how to merge customKolodaViewDelegate and the normal delegate.
        kolodaView.customKolodaViewDelegate = self
        do {
            audioPlayerWoosh = try AVAudioPlayer(contentsOf: wooshSound)
        }
        catch { }
        audioPlayerWoosh.prepareToPlay()
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal //not exactly sure how important this line is, but came with the Koloda code
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        self.buttonTappedHandler(index)
    }
    
    func koloda(kolodaShouldApplyAppearAnimation koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaShouldMoveBackgroundCard koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(kolodaShouldTransparentizeNextCard koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        let targetUser = userArray[Int(index)]
        if direction == .Right {
            dataStore.likePerson(targetUser)
        } else if direction == .Left {
            dataStore.nopePerson(targetUser)
        }
    }
    
    func calculateKolodaViewCardHeight() -> (cardHeight: CGFloat, navigationAreaHeight: CGFloat) {
        let bottomAreaHeight = theStackViewBottomConstraint.constant + theBottomButtonStackView.frame.height
        let cardOffsetFromBottomButtons : CGFloat = 0
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let frameHeight = self.view.frame.height
        let cardHeight = frameHeight - (bottomAreaHeight + cardOffsetFromBottomButtons) - (navigationBarHeight! + statusBarHeight)
        return (cardHeight, navigationBarHeight! + statusBarHeight)
    }
    
}

//MARK: KolodaViewDataSource
extension BackgroundAnimationViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> UInt {
        return UInt(userArray.count)
    }

    func koloda(_ koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let cardView = Bundle.main.loadNibNamed("CustomCardView", owner: self, options: nil)![0] as! CustomCardView
        
        cardView.backgroundColor = UIColor.clear
        cardView.userOfTheCard = userArray[Int(index)]
        
        return cardView
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        let overlayView : CustomOverlayView? = Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? CustomOverlayView
        return overlayView
    }
}


extension BackgroundAnimationViewController: MagicMoveable {
    var isMagic: Bool {
        return true
    }
    
    var duration: TimeInterval {
        return 0.5
    }
    
    var spring: CGFloat {
        return 0.7
    }
    
    fileprivate func buttonTappedHandler(_ index: UInt) {
        let cardDetailVC = UIStoryboard(name: Storyboards.main.storyboard, bundle: nil).instantiateViewController(withIdentifier: "CardDetailViewController") as! CardDetailViewController

        cardDetailVC.userOfTheCard = userArray[Int(index)]
        if let image = userArray[Int(index)].profileImage{
            self.theMagicMovePlaceholderImage.file = image
            self.theMagicMovePlaceholderImage.loadInBackground()
        } else {
            theMagicMovePlaceholderImage.backgroundColor = ChachaBombayGrey
        }
        
        //image is initially hidden, so then we can animate it to the next vc. A smoke and mirrors trick.
        theMagicMovePlaceholderImage.isHidden = false
        presentViewControllerMagically(self, to: cardDetailVC, animated: true, duration: duration, spring: spring)
    }
    
    var magicViews: [UIView] {
        return [theMagicMovePlaceholderImage]
    }
}

extension BackgroundAnimationViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case OnboardingPageSegue
        case CustomBackgroundAnimationToSearchSegue
        case BackgroundAnimationPageToAddingTagsPageSegue
        case BackgroundAnimationToMatchesSegue
        case BackgroundAnimationToProfileIndexSegue
    }
}

