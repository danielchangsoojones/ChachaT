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

private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1
var wooshSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("woosh", ofType: "wav")!)
var audioPlayerWoosh = AVAudioPlayer()
private let numberOfCards : UInt = 5

//go to Yalantis/Koloda github to see examples/more documentation on what Koloda is. 
class BackgroundAnimationViewController: UIViewController, CustomCardViewDelegate {
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var theMagicMovePlaceholderImage: PFImageView!
    
    var userArray = [User]()
    
    var pageMainViewControllerDelegate: PageMainViewControllerDelegate?
    
    @IBAction func segueToProfilePage(sender: AnyObject) {
        pageMainViewControllerDelegate!.moveToPageIndex(1)
    }
    
    @IBAction func logOut(sender: AnyObject) {
        User.logOut()
        performSegueWithIdentifier(.LogInPageSegue, sender: self)
    }
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if User.currentUser() == nil {
            performSegueWithIdentifier(.LogInPageSegue, sender: self)
        }
        
    }
    
    func playSoundInBG(theAudioPlayer:AVAudioPlayer) {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            theAudioPlayer.play()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

}

//queries
extension BackgroundAnimationViewController {
    func createUserArray() {
        let query = User.query()
        query?.whereKey("objectId", notEqualTo: (User.currentUser()?.objectId)!)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if let users = objects as? [User] {
                self.userArray = users
                self.kolodaView.reloadData()
            }
        })
    }
}

//MARK: KolodaViewDelegate
extension BackgroundAnimationViewController: KolodaViewDelegate {
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
    
    func koloda(koloda: KolodaView, isSwipingCardInDirection direction: SwipeResultDirection) {
        playSoundInBG(audioPlayerWoosh)
    }
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
    
    }
}

//MARK: KolodaViewDataSource
extension BackgroundAnimationViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(userArray.count)
    }
  
    func didTapImage(img: UIImage) {
        
    }

    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        guard let cardView = NSBundle.mainBundle().loadNibNamed("CustomCardView", owner: self, options: nil)[0] as? CustomCardView else { return UIView() }
        
        cardView.backgroundColor = UIColor.clearColor()
        cardView.delegate = self
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
        case LogInPageSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}

