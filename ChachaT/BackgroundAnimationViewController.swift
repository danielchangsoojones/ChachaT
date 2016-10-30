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
import EZSwiftExtensions

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
    @IBOutlet weak var theBottomButtonStackView: UIStackView!
    var fakeNavigationBar: FakeNavigationBarView!
    
    //constraint outlets
    @IBOutlet weak var theStackViewBottomConstraint: NSLayoutConstraint!

    var swipeArray = [Swipe]()
    fileprivate var dataStore : BackgroundAnimationDataStore!
    var rippleHasNotBeenStarted = true
    var prePassedSwipeArray = false
    
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
        dataStoreSetup()
        bottomBlurAreaSetup()
        setKolodaAttributes()
        setFakeNavigationBarView()
        if swipeArray.isEmpty {
            //if swipe array is empty, then that means we should load swipes
            //if it is not empty, that means the swipeArray was passed from the search page, so don't load new swipes
            dataStore.loadSwipeArray()
        }
        anonymousUserSetup()
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
        //we have to set the kolodaView dataSource in viewDidAppear because there is a bug in the Koloda cocoapod. When you have data preset (like when we pass the user array from 8tracks search page). The koloda Card view doesn't show correctly, it is misplaced. So, we have to wait to load it in viewDidAppear, for it to load correctly, until the Koloda cocoapod is upgraded to fix this. We have to wait until ViewDidAppear, instead of ViewDidLoad to implement this because in viewDidLoad and ViewWillAppear, the koloda cards aren't sized correctly yet, so they show up in weird forms/positions until we get to ViewDidAppear. This is kind of a hacky fix, until the Koloda cocoapod deals with this.
        if prePassedSwipeArray {
            kolodaView.dataSource = self
            kolodaView.reloadData()
        }
        getUserLocation()
    }
    
    func dataStoreSetup() {
        self.dataStore = BackgroundAnimationDataStore(delegate: self)
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
        fakeNavigationBar = FakeNavigationBarView(navigationBarHeight: self.navigationController!.navigationBar.frame.height, delegate: self)
        self.view.addSubview(fakeNavigationBar)
        fakeNavigationBar.snp.makeConstraints { (make) in
            make.trailing.leading.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(self.navigationController!.navigationBar.frame.height + ImportantDimensions.StatusBarHeight)
        }
    }
    
    func bottomBlurAreaSetup() {
        let blur = setBottomBlur(blurHeight: ez.screenHeight * 0.33, color: CustomColors.JellyTeal)
        self.view.layer.insertSublayer(blur, at: 0)
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
        for _ in 0...koloda.currentCardIndex - 1 {
            //we want to remove any swipes that we have just swiped because we don't want the user swiping the same users. We do currentCardIndex - 1, because the currentCardIndex is one ahead because we just did a swipe. We don't want to just empty the array either because sometimes we load the data while the user is swiping, so some swipes in the stack have not been interacted with yet.
            swipeArray.removeFirst()
        }
        kolodaView.resetCurrentCardIndex()
        dataStore.getMoreSwipes()
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
        let currentSwipe = swipeArray[Int(index)]
        if direction == .Right {
            currentSwipe.approve()
            dataStore.swipe(swipe: currentSwipe)
            if currentSwipe.isMatch {
                performSegue(withIdentifier: SegueIdentifier.BackgroundAnimationToMatchNotificationSegue.rawValue, sender: nil)
            }
        } else if direction == .Left {
            currentSwipe.nope()
            dataStore.swipe(swipe: currentSwipe)
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
        return UInt(swipeArray.count)
    }

    func koloda(_ koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let cardView = Bundle.main.loadNibNamed("CustomCardView", owner: self, options: nil)![0] as! CustomCardView
        
        cardView.backgroundColor = UIColor.clear
        cardView.userOfTheCard = swipeArray[Int(index)].otherUser
        
        return cardView
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        let overlayView : CustomOverlayView? = Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? CustomOverlayView
        return overlayView
    }
}

extension BackgroundAnimationViewController: FrostedSidebarDelegate {
    func sidebar(_ sidebar: FrostedSidebar, didTapItemAtIndex index: Int) {
        switch index {
        case 0:
            performSegueWithIdentifier(.BackgroundAnimationToMatchesSegue, sender: nil)
        case 1:
            performSegue(withIdentifier: SegueIdentifier.BackgroundAnimationPageToAddingTagsPageSegue.rawValue, sender: nil)
        case 2:
            performSegue(withIdentifier: SegueIdentifier.BackgroundAnimationToProfileIndexSegue.rawValue, sender: nil)
        default:
            break
        }
    }
    
    func sidebar(_ sidebar: FrostedSidebar, didShowOnScreenAnimated animated: Bool) {}
    func sidebar(_ sidebar: FrostedSidebar, willShowOnScreenAnimated animated: Bool) {}
    func sidebar(_ sidebar: FrostedSidebar, didEnable itemEnabled: Bool, itemAtIndex index: Int) {}
    func sidebar(_ sidebar: FrostedSidebar, didDismissFromScreenAnimated animated: Bool) {}
    func sidebar(_ sidebar: FrostedSidebar, willDismissFromScreenAnimated animated: Bool) {}
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

        cardDetailVC.userOfTheCard = swipeArray[Int(index)].otherUser
        if let image = swipeArray[Int(index)].otherUser.profileImage{
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
        case CustomBackgroundAnimationToSearchSegue
        case BackgroundAnimationPageToAddingTagsPageSegue
        case BackgroundAnimationToMatchesSegue
        case BackgroundAnimationToProfileIndexSegue
        case BackgroundAnimationToMatchNotificationSegue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case .BackgroundAnimationToMatchNotificationSegue:
            let destinationVC = segue.destination as! MatchNotificationViewController
            //Creates a transparent overlay of this page, with the matches information.
            destinationVC.otherUser = swipeArray[kolodaView.currentCardIndex - 1].otherUser //go back one index because we just swiped the user to match
            destinationVC.modalPresentationStyle = .custom
            destinationVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            destinationVC.view.isOpaque = false
        default:
            break
        }
    }
}

