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
import CoreLocation
import EFTools
import Ripple
import SnapKit
import EZSwiftExtensions
import Instructions

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
    @IBOutlet weak var theChachaLoadingImage: UIImageView!
    @IBOutlet weak var theBackgroundColorView: UIView!
    @IBOutlet weak var theBottomButtonsView: BottomButtonsView!
    var fakeNavigationBar: FakeNavigationBarView!
    
    //constraint outlets
    @IBOutlet weak var theStackViewBottomConstraint: NSLayoutConstraint!

    var swipeArray = [Swipe]()
    var dataStore : BackgroundAnimationDataStore!
    var rippleHasNotBeenStarted = true
    var prePassedSwipeArray = false
    var theTappedKolodaIndex: Int = 0
    
    let coachMarksController = CoachMarksController()
    var showTutorial: Bool = false
    
    let locationManager = CLLocationManager()
    
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
        setBottomButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true //created a fake nav bar, so want to hide the real nav bar whenever I come on the screen
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
            prePassedSwipeArray = false
            kolodaView.dataSource = self
            kolodaView.reloadData()
        }
        getUserLocation()
        setUpTutorialCoachingMarks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.coachMarksController.stop(immediately: true)
    }
    
    func dataStoreSetup() {
        self.dataStore = BackgroundAnimationDataStore(delegate: self)
    }
    
    func setBottomButtons() {
        theBottomButtonsView.setBottomButtonImages(addMessageButton: true, delegate: self, style: .transparent)
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

extension BackgroundAnimationViewController: BottomButtonsDelegate {
    func approveButtonPressed() {
        kolodaView.swipe(.right)
    }
    
    func nopeButtonPressed() {
        kolodaView.swipe(.left)
    }
    
    func messageButtonPressed() {
        let currentIndex = kolodaView.currentCardIndex
        if swipeArray.indices.contains(currentIndex) {
            CardSendMessageViewController.presentFrom(self, userToSend: swipeArray[currentIndex].otherUser)
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

//MARK: KolodaViewDelegate
extension BackgroundAnimationViewController: CustomKolodaViewDelegate {
    //WARNING: SOMETIMES THE KOLODAVIEWDELEGATE FUNCTIONS CHANGE NAMES WHEN COCOAPOD IS UPDATED AND IT DOESN'T THROW AN ERROR FOR SOME REASON, SO MAKE SURE FUNCTION NAMES AND PARAMETERS MATCH PERFECTLY IF SOMETHING SEEMS TO BREAK
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
        if let lastSwipe = swipeArray.last {
            dataStore.getMoreSwipes(lastSwipe: lastSwipe)
        }
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        self.buttonTappedHandler(index)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let currentSwipe = swipeArray[Int(index)]
        if direction == .right {
            currentSwipe.approve()
            if currentSwipe.isMatch {
                performSegue(withIdentifier: SegueIdentifier.BackgroundAnimationToMatchNotificationSegue.rawValue, sender: nil)
            }
        } else if direction == .left {
            currentSwipe.nope()
        }
        
        if index < swipeArray.count - 1 {
            //on the last card, the didRunOutOfCards function is called to save the swipe because we want to save the swipe before we check to see what swipes we can still pull from the database
            dataStore.swipe(swipe: currentSwipe)
        }
    }
    
    func calculateKolodaViewCardHeight() -> (cardHeight: CGFloat, navigationAreaHeight: CGFloat) {
        let bottomAreaHeight = theStackViewBottomConstraint.constant + theBottomButtonsView.frame.height
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
    public func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return swipeArray.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let cardView = Bundle.main.loadNibNamed("CustomCardView", owner: self, options: nil)![0] as! CustomCardView
        
        let currentSwipe = swipeArray[Int(index)]
        cardView.backgroundColor = UIColor.clear
        cardView.userOfTheCard = currentSwipe.otherUser
        
        if currentSwipe.incomingMessage != nil {
            addCardMessageChildVC(toView: cardView, swipe: currentSwipe)
        }
        return cardView
    }
    
    fileprivate func addCardMessageChildVC(toView: UIView, swipe: Swipe) {
        let childVC = NewCardMessageViewController()
        childVC.swipe = swipe
        childVC.delegate = self
        addAsChildViewController(childVC, toView: toView)
        //For some reason, I have to snap the child's view to the top of the koloda card. Not really sure why, but if I don't, then the messageView top is above the card. Must be because of how koloda Cards are presented or something. I'm not really sure.
        childVC.view.snp.makeConstraints { (make) in
            make.top.equalTo(toView)
        }
    }
    
    //Need to do Koloda.OverlayView because Instructions pod also has a view called OverlayView, so it was ambigious
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> Koloda.OverlayView? {
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
    
    fileprivate func buttonTappedHandler(_ index: Int) {
        let cardDetailVC = UIStoryboard(name: Storyboards.main.storyboard, bundle: nil).instantiateViewController(withIdentifier: "CardDetailViewController") as! CardDetailViewController
        cardDetailVC.newCardMessageViewControllerDelegate = self
        cardDetailVC.delegate = self
        cardDetailVC.swipe = swipeArray[index]
        theTappedKolodaIndex = index
        
        presentViewControllerMagically(self, to: cardDetailVC, animated: true, duration: duration, spring: spring)
    }
    
    var magicViews: [UIView] {
        get {
            let currentCardView = kolodaView.viewForCard(at: theTappedKolodaIndex) as! CustomCardView
            return [currentCardView.theCardMainImage]
        }
    }
}

extension BackgroundAnimationViewController: EmptyStateDelegate {
    func emptyStateButtonPressed() {
        performSegue(withIdentifier: SegueIdentifier.CustomBackgroundAnimationToSearchSegue.rawValue, sender: nil)
    }
}

extension BackgroundAnimationViewController: NewCardMessageControllerDelegate {
    func removeMessageFromSwipe() {
        removeNewCardMessageController()
    }
    
    func removeNewCardMessageController() {
        for childVC in childViewControllers {
            if let cardMessageController = childVC as? NewCardMessageViewController {
                cardMessageController.removeSelf()
            }
        }
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
        case .CustomBackgroundAnimationToSearchSegue:
            let destinationVC = segue.destination as! SearchTagsViewController
            destinationVC.showTutorial = showTutorial
            showTutorial = false
        default:
            break
        }
    }
}

