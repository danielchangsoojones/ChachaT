//
//  SecondVC.swift
//  MagicMove
//
//  Created by Patrick Reynolds on 1/24/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit
import EFTools
import SCLAlertView
import EZSwiftExtensions

class CardDetailViewController: UIViewController {
    @IBOutlet weak var theBulletPointsStackView: UIStackView!
    @IBOutlet weak var theDescriptionDetailView: DescriptionDetailView!
    @IBOutlet weak var theTagListViewHolder: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!

    var theTagCreationViewController: TagCreationViewController!
    
    //constraints
    @IBOutlet weak var theDetailViewHolderHeight: NSLayoutConstraint!
    
    
    var userOfTheCard: User? = User.current() //just setting a defualt, should be passed through dependency injection
    //TODO: we really only need to take in a swipe to the cardDetailPage, and then we can set the userOfTheCard from there
    var swipe: Swipe? {
        didSet {
            userOfTheCard = swipe?.otherUser
        }
    }

    var dataStore: CardDetailDataStore!
    
    var newCardMessageViewControllerDelegate: NewCardMessageControllerDelegate?
    var delegate: BottomButtonsDelegate?
    
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
        addTagListViewChildVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let superview = self.view.superview {
            theDetailViewHolderHeight.constant = superview.frame.height
        }
    }
    
    fileprivate func addTagListViewChildVC() {
        theTagCreationViewController = TagCreationViewController(delegate: self)
        addAsChildViewController(theTagCreationViewController, toView: theTagListViewHolder)
        theTagCreationViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func dataStoreSetup() {
        dataStore = CardDetailDataStore(delegate: self)
    }
    
    func setNormalGUI() {
        dataStore.loadTags(user: userOfTheCard!)
        scrollViewSetup()
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
//        setBottomButtons()
    }
    
    func bulletPointSetup(_ text: String, width: CGFloat) {
        let bulletPointView = BulletPointView(text: text, width: width)
        theBulletPointsStackView.addArrangedSubview(bulletPointView)
    }
    
    func scrollViewSetup() {
        theScrollView.showsVerticalScrollIndicator = false
    }
    
    //TODO: do I really need to have bottom buttons on this area?
//    func setBottomButtons() {
//        //setting the height to the nopeButton's height because that is the height of the view
//        if delegate != nil {
//            self.view.layer.addSublayer(setBottomBlur(blurHeight: ez.screenHeight * 0.23, color: CustomColors.JellyTeal))
//            let bottomButtonsView = BottomButtonsView(addMessageButton: true, delegate: self, style: .filled)
//            self.view.addSubview(bottomButtonsView)
//            bottomButtonsView.snp.makeConstraints { (make) in
//                make.bottom.equalToSuperview()
//                make.centerX.equalToSuperview()
//            }
//        }
//    }
}

//extension CardDetailViewController: BottomButtonsDelegate {
//    func nopeButtonPressed() {
//        dismiss(animated: false, completion: {
//            self.delegate?.nopeButtonPressed()
//        })
//    }
//    
//    func approveButtonPressed() {
//        dismiss(animated: false, completion: {
//            self.delegate?.approveButtonPressed()
//        })
//    }
//    
//    func messageButtonPressed() {
//        if let userOfTheCard = userOfTheCard {
//            CardSendMessageViewController.presentFrom(self, userToSend: userOfTheCard)
//        }
//    }
//}

extension CardDetailViewController: TagCreationViewControllerDelegate {
    func keyboardChanged(keyboardHeight: CGFloat) {
        theScrollView.contentInset.bottom = keyboardHeight
        if keyboardHeight > 0 {
            ez.runThisAfterDelay(seconds: 0.2, after: {
                //TODO: I honestly have no fucking idea why I had to put a delay on scrolling to a certain point. I don't know why this works, but if I don't use a delay, then it scrolls funkily.
                let visibleRect = self.theTagListViewHolder.frame
                self.theScrollView.scrollRectToVisible(visibleRect, animated: true)
            })
        }
    }
    
    func searchForTags(searchText: String) {
        dataStore.searchForTags(searchText: searchText, delegate: self)
    }
    
    func saveNewTag(title: String) {
        dataStore.saveTag(title: title, userForTag: userOfTheCard ?? User.current()!)
        createChosenTagView(title: title)
    }
    
    fileprivate func createChosenTagView(title: String) {
        addPendingTagView(title: title)
    }
    
    fileprivate func addPendingTagView(title: String) {
        let pendingTagView = PendingTagView(title: title, topLabelTitle: "Pending...")
        theTagCreationViewController.insertTagViewAtFront(tagView: pendingTagView)
    }
}

extension CardDetailViewController: TagDataStoreDelegate {
    func setChoicesViewTagsArray(_ tagChoicesDataArray: [Tag]) {}
    
    func passSearchResults(searchTags: [Tag]) {
        dataStore.setSearchedTags(tags: searchTags)
        theTagCreationViewController.passSearchedTags(searchTags: searchTags)
    }
    
    func getMostCurrentSearchText() -> String {
        return theTagCreationViewController.getCurrentSearchText()
    }
}

extension CardDetailViewController: CardDetailDataStoreDelegate {
    func passTags(tagArray: [Tag]) {
        for tag in tagArray {
            if tag.isPending {
                addPendingTagView(title: tag.title)
            } else {
                _ = theTagCreationViewController.creationTagListView.addTag(tag.title)
            }
        }
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

extension CardDetailViewController {
    class func createCardDetailVC(userOfCard: User?) -> CardDetailViewController {
        let cardDetailVC = UIStoryboard(name: Storyboards.main.storyboard, bundle: nil).instantiateViewController(withIdentifier: "CardDetailViewController") as! CardDetailViewController
        cardDetailVC.userOfTheCard = userOfCard
        return cardDetailVC
    }
    
    class func addAsChildVC(to vc: UIViewController, toView: BumbleDetailView, user: User) {
        let childVC = CardDetailViewController.createCardDetailVC(userOfCard: user)
        vc.addAsChildViewController(childVC, toView: toView)
        toView.theCardDetailViewController = childVC
        childVC.view.frame = toView.bounds
    }
}
