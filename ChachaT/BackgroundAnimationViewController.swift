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
import BlurryModalSegue
import Ripple
import SnapKit
import Timepiece

private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1
var wooshSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("woosh", ofType: "wav")!)
var audioPlayerWoosh = AVAudioPlayer()
private let numberOfCards : UInt = 5

//go to Yalantis/Koloda github to see examples/more documentation on what Koloda is. 
class BackgroundAnimationViewController: OverlayAnonymousFlowViewController {
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var theMagicMovePlaceholderImage: PFImageView!
    @IBOutlet weak var theChachaLoadingImage: UIImageView!
    @IBOutlet weak var theBackgroundColorView: UIView!
    @IBOutlet weak var theFilteringButton: UIButton!

    var userArray = [User]()
    
    var pageMainViewControllerDelegate: PageMainViewControllerDelegate?
    
    @IBAction func segueToProfilePage(sender: AnyObject) {
        pageMainViewControllerDelegate!.moveToPageIndex(1)
    }
    
    @IBAction func skipCard(sender: AnyObject) {
        kolodaView.swipe(.Right)
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createAnonymousFlow()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        do {
            audioPlayerWoosh = try AVAudioPlayer(contentsOfURL: wooshSound)
        }
        catch { }
        
        audioPlayerWoosh.prepareToPlay()
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        createUserArray()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.theMagicMovePlaceholderImage.hidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rippleState += 1
        //need to only do on rippleState 3 because the frame is not set for the center of the chachaLoadingImage
        //I could not find the method to show when the frames are correct. This was the hacky way to get it to work.
        if rippleState == 3 {
            ripple(theChachaLoadingImage.center, view: self.theBackgroundColorView)
        } else if rippleState == 6 {
            if anonymousFlowStage(.MainPageFirstVisitMatchingPhase) {
                ripple(theOverlayView.center, view: self.theOverlayView)
            }
        }
    }
    
    func playSoundInBG(theAudioPlayer:AVAudioPlayer) {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            theAudioPlayer.play()
        })
    }

}

//queries
extension BackgroundAnimationViewController {
    func createUserArray() {
        //creating the anonymous flow for a new user, so the users learns how to use the app.
        if anonymousFlowStage(.MainPageFirstVisitMatchingPhase) {
            userArray = [createFirstPlaceholderUser()]
            self.kolodaView.reloadData()
        } else {
            //normal creating of the stack.
            let query = User.query()
            if let objectId = User.currentUser()?.objectId {
                query?.whereKey("objectId", notEqualTo: objectId)
            }
            query?.whereKey("anonymous", equalTo: false)
            query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let users = objects as? [User] {
                    self.userArray = users
                    self.kolodaView.reloadData()
                }
            })
        }
    }
}

//MARK: KolodaViewDelegate
extension BackgroundAnimationViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        //this means the user tapped the sign up card
        if anonymousFlowStage(.MainPageThirdVisitSignUpPhase) && (Int(index) == 3 || (Int(index) == userArray.count && userArray.count < 4)) {
            performSegueWithIdentifier(.MainTinderPageToQuestionOnboardingSegue, sender: self)
        } else {
            //go through the normal user process
            self.buttonTappedHandler(index)
        }
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
    
    func koloda(koloda: KolodaView, isSwipingCardInDirection direction: SwipeResultDirection) {
        playSoundInBG(audioPlayerWoosh)
    }
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
    
    }
}

//MARK: KolodaViewDataSource
extension BackgroundAnimationViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        if anonymousFlowStage(.MainPageThirdVisitSignUpPhase) {
            //the user can see 3 cards, and then they need to sign up. 
            return UInt(userArray.count + 1)
        } else {
            return UInt(userArray.count)
        }
    }

    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        guard let cardView = NSBundle.mainBundle().loadNibNamed("CustomCardView", owner: self, options: nil)[0] as? CustomCardView else { return UIView() }
        
        //to make a sign up card for anonymous users on the 4th card.
        if anonymousFlowStage(.MainPageThirdVisitSignUpPhase) && (Int(index) == 3 || (Int(index) == userArray.count && userArray.count < 4)) {
            cardView.theCardMainImage.image = UIImage(named: "ChachaSignUpCardImage")
        } else {
            //do the normal indexing of users to cards
            cardView.backgroundColor = UIColor.clearColor()
            cardView.userOfTheCard = userArray[Int(index)]
        }
        
        //special case for PFAnonymous User going through anonymous flow
        if anonymousFlowStage(.MainPageFirstVisitMatchingPhase) {
            cardView.theCardMainImage.image = UIImage(named: "DrivingGirl")
        }
        
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
            if anonymousFlowStage(.MainPageFirstVisitMatchingPhase) {
                theMagicMovePlaceholderImage.image = UIImage(named: "DrivingGirl")
            } else {
                theMagicMovePlaceholderImage.backgroundColor = ChachaBombayGrey
            }
        }
        
        //image is initially hidden, so then we can animate it to the next vc. A smoke and mirrors trick.
        theMagicMovePlaceholderImage.hidden = false
        presentViewControllerMagically(self, to: cardDetailVC, animated: true, duration: duration, spring: spring)
    }
    
    var magicViews: [UIView] {
        return [theMagicMovePlaceholderImage]
    }
}

//creating the overlay/anonymous flow
extension BackgroundAnimationViewController {
    func createFirstTapCardHandOverlay() {
        let theHandImage = createHandImageOverlay()
        createSemiTranslucentBlackOverlay([theHandImage])
        
        theHandImage.snp_makeConstraints { (make) in
            make.center.equalTo(theOverlayView).offset(CGPointMake(20, 30))
        }
    }
    
    func createSecondTapFilteringHandOverlay() {
        let theHandImage = createHandImageOverlay()
        let overlayLabel = createLabelForOverlay("Filter who you want to see!")
        createSemiTranslucentBlackOverlay([theHandImage, overlayLabel])
        
        theHandImage.snp_makeConstraints { (make) in
            make.center.equalTo(theFilteringButton).offset(CGPointMake(40, 50))
        }
        overlayLabel.snp_makeConstraints { (make) in
            make.center.equalTo(theOverlayView)
        }
    }
    
    func createAnonymousFlow() {
        if PFAnonymousUtils.isLinkedWithUser(User.currentUser()) {
            switch anonymousFlowGlobal {
            case .MainPageFirstVisitMatchingPhase: createFirstTapCardHandOverlay()
            case .MainPageSecondVisitFilteringStage: createSecondTapFilteringHandOverlay()
            case .MainPageThirdVisitSignUpPhase: removeOverlay()
            }
        }
    }
    
    func createFirstPlaceholderUser() -> User {
        let placeholderUser = User()
        placeholderUser.title = "Graphic Designer"
        placeholderUser.birthDate = NSDate.date(year: 1995, month: 6, day: 2)
        placeholderUser.fullName = "Taylor Johnson"
        placeholderUser.factOne = "I have never missed a day of school. Ever."
        placeholderUser.factTwo = "Shaq has my autograph."
        placeholderUser.factThree = "I'm an identical twin."
        placeholderUser.questionOne = createQuestion("What's a clear sign that someone was raised well?", answerString: "When someone is obviously in the wrong, and they know it, they apologize and work towards not making a mistake like that again. Most people will deny it until the other person gives up, or get all defensive about how it was not a big deal.")
        return placeholderUser
    }
    
    func createQuestion(questionString: String, answerString: String) -> Question {
        let question = Question()
        question.question = questionString
        question.topAnswer = answerString
        return question
    }
}

extension BackgroundAnimationViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case LogInPageSegue
        case FilterPageBlurrySegue
        case MainTinderPageToQuestionOnboardingSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .FilterPageBlurrySegue:
            let destinationVC = segue.destinationViewController as! FilterViewController
            destinationVC.delegate = self
            let blurrySegue = segue as! BlurryModalSegue
            blurrySegue.backingImageTintColor = BlurryFilteringPageBackground
            blurrySegue.backingImageSaturationDeltaFactor = 0.2
        // Do some things
        case .MainTinderPageToQuestionOnboardingSegue:
            let navigationVC = segue.destinationViewController as! UINavigationController
            let destinationVC = navigationVC.viewControllers[0] as! QuestionPopUpViewController
            destinationVC.fromOnboarding = true
            destinationVC.questionPopUpState = .EditingMode
        default: break
        }
    }
}

protocol FilterViewControllerDelegate {
    func passFilteredUserArray(filteredUserArray: [User])
    func updateAnonymousFlow()
}
extension BackgroundAnimationViewController: FilterViewControllerDelegate {
    func passFilteredUserArray(filteredUserArray: [User]) {
        userArray = filteredUserArray
        self.kolodaView.reloadData()
    }
    
    func updateAnonymousFlow() {
        createAnonymousFlow()
    }
}

