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
var wooshSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("woosh", ofType: "wav")!)
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
    private var matchDataStore = MatchDataStore.sharedInstance
    var rippleHasNotBeenStarted = true
    
    var pageMainViewControllerDelegate: PageMainViewControllerDelegate?
    
    @IBAction func segueToProfilePage(sender: AnyObject) {
        pageMainViewControllerDelegate!.moveToPageIndex(1)
    }
    
    @IBAction func skipCard(sender: AnyObject) {
        kolodaView.swipe(.Left)
    }
    
    @IBAction func approveCard(sender: UIButton) {
        kolodaView.swipe(.Right)
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(ez.appVersion)
        theBackgroundColorView.backgroundColor = BackgroundPageColor
        setKolodaAttributes()
        setFakeNavigationBarView()
        if userArray.isEmpty {
            //if user array is empty, then that means we should load users
            //if it is not empty, that means the userArray was passed from the search page, so don't load new users
            createUserArray()
        }
        
//        let tags = Tags()
//        tags.createdBy = User.currentUser()!
//        tags.genericTags = ["banana", "apple", "pear"]
//        tags.gender = 302
//        tags.ethnicity = 2
//        tags.sexuality = 402
//        tags.politicalGroup = -201
//        tags.hairColor = -101
//        tags.birthDate = NSDate.date(year: 1996, month: 4, day: 6)
//        tags.saveInBackground()
        
//        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) in
//            if error == nil {
//                let tags = Tags()
//                tags.createdBy = User.currentUser()!
//                tags.genericTags = ["banana", "apple", "pear"]
//                tags.gender = 302
//                tags.ethnicity = 2
//                tags.sexuality = 402
//                tags.politicalGroup = -201
//                tags.hairColor = -101
//                tags.location = geoPoint!
//                tags.birthDate = NSDate.date(year: 1996, month: 4, day: 6)
//                tags.saveInBackground()
//            }
//        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true //created a fake nav bar, so want to hide the real nav bar whenever I come on the screen
        self.theMagicMovePlaceholderImage.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if rippleHasNotBeenStarted {
            //only want to have ripple appear once, if we leave th page via pageviewcontroller, the view appears again and would think to start a second ripple.
            //this makes it only appear the first run time.
            ripple(theChachaLoadingImage.center, view: theBackgroundColorView)
            rippleHasNotBeenStarted = false
        }
    }
    
    func playSoundInBG(theAudioPlayer:AVAudioPlayer) {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            theAudioPlayer.play()
        })
    }
    
    //Purpose: we created a fake navigation bar because we are turning off the normal navigation bar. Then, we use this view as a fake navigation bar that the user can't tell the difference. We need to do this because we need the view to grow to include the left side menu drop down menu. The normal nav bar shows the buttons, but they aren't clickable because they are outside the nav bars bounds. So, we need to make this view's frame grow, so the buttons become clickable.
    func setFakeNavigationBarView() {
        let fakeNavigationBarView = FakeNavigationBarView(navigationBarHeight: self.navigationController!.navigationBar.frame.height, delegate: self)
        self.view.addSubview(fakeNavigationBarView)
        fakeNavigationBarView.snp_makeConstraints { (make) in
            make.trailing.leading.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(self.navigationController!.navigationBar.frame.height + ImportantDimensions.StatusBarHeight)
        }
    }
    
}

//queries
extension BackgroundAnimationViewController {
    func createUserArray() {
            //normal creating of the stack.
            let query = User.query()
            if let objectId = User.currentUser()?.objectId {
                query?.whereKey("objectId", notEqualTo: objectId)
            }
            query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let users = objects as? [User] {
                    self.userArray = users
                    self.kolodaView.reloadData()
                }
            })
    }
}

//MARK: KolodaViewDelegate
//BEWARE if the function is not being run, it is because some of the delegate names have been changed. Go to the delegate page and make sure they match up exactly
extension BackgroundAnimationViewController: KolodaViewDelegate, CustomKolodaViewDelegate {
    func setKolodaAttributes() {
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        //TODO: figure out how to merge customKolodaViewDelegate and the normal delegate.
        kolodaView.customKolodaViewDelegate = self
        kolodaView.dataSource = self
        do {
            audioPlayerWoosh = try AVAudioPlayer(contentsOfURL: wooshSound)
        }
        catch { }
        audioPlayerWoosh.prepareToPlay()
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal //not exactly sure how important this line is, but came with the Koloda code
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
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
        animation.springBounciness = frameAnimationSpringBounciness
        animation.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        let targetUser = userArray[Int(index)]
        if direction == .Right {
            matchDataStore.likePerson(targetUser)
        } else if direction == .Left {
            matchDataStore.nopePerson(targetUser)
        }
    }
    
    func calculateKolodaViewCardHeight() -> (cardHeight: CGFloat, navigationAreaHeight: CGFloat) {
        let bottomAreaHeight = theStackViewBottomConstraint.constant + theBottomButtonStackView.frame.height
        let cardOffsetFromBottomButtons : CGFloat = 0
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let frameHeight = self.view.frame.height
        let cardHeight = frameHeight - (bottomAreaHeight + cardOffsetFromBottomButtons) - (navigationBarHeight! + statusBarHeight)
        return (cardHeight, navigationBarHeight! + statusBarHeight)
    }
    
}

//MARK: KolodaViewDataSource
extension BackgroundAnimationViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(userArray.count)
    }

    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        guard let cardView = NSBundle.mainBundle().loadNibNamed("CustomCardView", owner: self, options: nil)[0] as? CustomCardView else { return UIView() }
        
        cardView.backgroundColor = UIColor.clearColor()
        cardView.userOfTheCard = userArray[Int(index)]
        
        //Rounded corners
        cardView.layer.cornerRadius = 10.0
        cardView.layer.masksToBounds = true
        
        return cardView
    }

    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView",
                                                  owner: self, options: nil)[0] as? OverlayView
    }
}


extension BackgroundAnimationViewController: MagicMoveable {
    var isMagic: Bool {
        return true
    }
    
    var duration: NSTimeInterval {
        return 0.5
    }
    
    var spring: CGFloat {
        return 0.7
    }
    
    private func buttonTappedHandler(index: UInt) {
        let cardDetailVC = UIStoryboard(name: Storyboards.Main.storyboard, bundle: nil).instantiateViewControllerWithIdentifier(String(CardDetailViewController)) as! CardDetailViewController

        cardDetailVC.userOfTheCard = userArray[Int(index)]
        if let image = userArray[Int(index)].profileImage{
            self.theMagicMovePlaceholderImage.file = image
            self.theMagicMovePlaceholderImage.loadInBackground()
        } else {
            theMagicMovePlaceholderImage.backgroundColor = ChachaBombayGrey
        }
        
        //image is initially hidden, so then we can animate it to the next vc. A smoke and mirrors trick.
        theMagicMovePlaceholderImage.hidden = false
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
    }
}

