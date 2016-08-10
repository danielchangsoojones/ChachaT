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
        theBackgroundColorView.backgroundColor = BackgroundPageColor
        setNavigationButtons()
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
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        if userArray.isEmpty {
            //if user array is empty, then that means we should load users
            //if it is not empty, that means the userArray was passed from the search page, so don't load new users
            createUserArray()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func setNavigationButtons() {
        //need to hold the uinavigation button in a variable because we will be turning the actual navBarItems to nil when we want to disappear
        //then when we want them to reappear, we will set back to our retained global variable.
        leftNavigationButton = createNavigationButton("Notification Tab Icon", buttonAction: #selector(BackgroundAnimationViewController.logOut))
        self.navigationItem.leftBarButtonItem = leftNavigationButton
        rightNavigationButton = createNavigationButton("SearchIcon", buttonAction: #selector(BackgroundAnimationViewController.searchNavigationButtonPressed))
        self.navigationItem.rightBarButtonItem = rightNavigationButton
    }
    
    func createNavigationButton(imageName: String, buttonAction: Selector) -> UIBarButtonItem {
//        let navigationButtonAlpha : CGFloat = 0.75
        let navigationButtonSideDimension : CGFloat = 20
        let button = UIButton()
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        button.addTarget(self, action:buttonAction, forControlEvents: UIControlEvents.TouchUpInside)
        button.frame=CGRectMake(0, 0, navigationButtonSideDimension, navigationButtonSideDimension)
//        button.alpha = navigationButtonAlpha
        return UIBarButtonItem(customView: button)
    }
    
    func logOut() {
        User.logOut()
        performSegueWithIdentifier(.OnboardingPageSegue, sender: self)
    }
    
    func searchNavigationButtonPressed() {
        performSegueWithIdentifier(SegueIdentifier.CustomBackgroundAnimationToSearchSegue, sender: self)
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
    }
}

