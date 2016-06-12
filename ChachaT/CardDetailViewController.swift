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

public enum QuestionDetailState {
    case EditingMode
    case ProfileViewOnlyMode
    case OtherUserProfileViewOnlyMode
}

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var profileImage: PFImageView!
    @IBOutlet weak var theFirstBulletText: UILabel!
    @IBOutlet weak var theCustomQuestionButton: UIButton!
    @IBOutlet weak var theProfileImageButtonOverlay: UIButton!
    @IBOutlet weak var theFullNameTextField: UITextField!
    @IBOutlet weak var theFullNameLabel: UILabel!
    @IBOutlet weak var theAgeLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theSecondBulletText: UILabel!
    @IBOutlet weak var theThirdBulletText: UILabel!
    @IBOutlet weak var editOrBackOrSaveButton: UIButton!
    @IBOutlet weak var theSavingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var theQuestionButtonOne: ResizableButton!
    @IBOutlet weak var theQuestionButtonTwo: ResizableButton!
    @IBOutlet weak var theQuestionButtonThree: ResizableButton!
    var theHandOverlayBackgroundColorView: UIView = UIView()
    
    var fullNameTextFieldDidChange = false
    var titleTextFieldDidChange = false
    var imageWasChanged = false
    //need to set this to editing if I want to have profile that is editable
    var questionDetailState : QuestionDetailState = .OtherUserProfileViewOnlyMode
    
    var userOfTheCard: User? = User.currentUser()
    
    @IBAction func editOrBackOrSavePressed(sender: AnyObject) {
        switch questionDetailState {
        case .EditingMode:
            //the user is editing right now, and will hit the save button to save their work
            if fullNameTextFieldDidChange {
                let fullNameText = theFullNameTextField.text
                userOfTheCard?.fullName = fullNameText
                userOfTheCard?.lowercaseFullName = fullNameText?.lowercaseString
            }
            theProfileImageButtonOverlay.setImage(nil, forState: .Normal)
            if imageWasChanged {
                let file = PFFile(name: "profileImage.jpg",data: UIImageJPEGRepresentation(profileImage.image!, 0.6)!)
                userOfTheCard!.profileImage = file
            }
            if titleTextFieldDidChange {
                userOfTheCard?.title = titleTextField.text
            }
            theFullNameTextField.userInteractionEnabled = false
            titleTextField.userInteractionEnabled = false
            theSavingSpinner.hidden = false
            theSavingSpinner.startAnimating()
            userOfTheCard?.saveInBackgroundWithBlock({ (success, error) in
                if success {
                    self.theSavingSpinner.stopAnimating()
                    self.theSavingSpinner.hidden = true
                    self.editOrBackOrSaveButton.setTitle("Edit", forState: .Normal)
                } else {
                    let _ = Alert(title: "Problem Saving Profile", subtitle: "Please try to save again", closeButtonTitle: "Okay", closeButtonHidden: false, type: .Error)
                }
            })
            questionDetailState = .ProfileViewOnlyMode
        case .ProfileViewOnlyMode:
            //the user is on the profile page, but not currently wanting to edit anything. Only looking.
                titleTextField.userInteractionEnabled = true
                theFullNameTextField.userInteractionEnabled = true
                editOrBackOrSaveButton.setTitle("Save", forState: .Normal)
                questionDetailState = .EditingMode
                setEditingGUI()
        case .OtherUserProfileViewOnlyMode:
            //the user is on the normal card view and looking at another user. This just dismisses the detail view back to the card stack
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    @IBAction func questionButtonOnePressed(sender: AnyObject) {
        createQuestionPopUp(PopUpQuestionNumber.QuestionOne)
    }
    
    @IBAction func questionButtonTwoPressed(sender: AnyObject) {
        createQuestionPopUp(PopUpQuestionNumber.QuestionTwo)
    }
    
    @IBAction func questionButtonThreePressed(sender: AnyObject) {
        createQuestionPopUp(PopUpQuestionNumber.QuestionThree)
    }

    
    @IBAction func customQuestionButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func reportAbuseButtonPressed(sender: AnyObject) {
        let alert = Alert(closeButtonHidden: false)
        alert.addButton("Block User") { 
            alert.closeAlert()
        }
       alert.createAlert("Report Abuse", subtitle: "The profile has been reported, and moderators will be examining the profile shortly.", closeButtonTitle: "Okay", type: .Error)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNormalGUI()
        createAnonymousFlow()
        setupTapHandler()
    }
    
    override func viewWillAppear(animated: Bool) {
        animateOverlay(theHandOverlayBackgroundColorView)
    }
    
    func createDetailPopUp(factNumber: Fact) {
        //look at STPopUp github for more info.
        let storyboard = UIStoryboard(name: "PopUp", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("UserDetailPopUpViewController") as! UserDetailPopUpViewController
        vc.delegate = self
        vc.factNumber = factNumber
        switch factNumber {
        case .FactOne:
            vc.factDescriptionText = theFirstBulletText.text
        case .FactTwo:
            vc.factDescriptionText = theSecondBulletText.text
        case .FactThree:
            vc.factDescriptionText = theThirdBulletText.text
        }
        let popup = STPopupController(rootViewController: vc)
        popup.containerView.layer.cornerRadius = 10.0
        popup.navigationBar.barTintColor = ChachaTeal
        popup.navigationBar.tintColor = UIColor.whiteColor()
        popup.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        popup.presentInViewController(self)
    }
    
    func createQuestionPopUp(questionNumber: PopUpQuestionNumber) {
        //look at STPopUp github for more info.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("UserDetailQuestionPopUpViewController") as! QuestionPopUpViewController 
        vc.delegate = self
        vc.popUpQuestionNumber = questionNumber
        switch questionNumber {
        case .QuestionOne: vc.currentQuestion = userOfTheCard?.questionOne
        case .QuestionTwo: vc.currentQuestion = userOfTheCard?.questionTwo
        case .QuestionThree: vc.currentQuestion = userOfTheCard?.questionThree
        case .CustomQuestion: break
        }
        if questionDetailState == .EditingMode {
            vc.questionPopUpState = .EditingMode
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let popup = STPopupController(rootViewController: vc)
            popup.containerView.layer.cornerRadius = 10.0
            popup.navigationBar.barTintColor = ChachaTeal
            popup.navigationBar.tintColor = UIColor.whiteColor()
            popup.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            popup.presentInViewController(self)
        }
        
    }
    
    func createBottomPicturePopUp() {
        let storyboard = UIStoryboard(name: "PopUp", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(StoryboardIdentifiers.BottomPicturePopUpViewController.rawValue) as! BottomPicturePopUpViewController
        vc.bottomPicturePopUpViewControllerDelegate = self
        vc.profileImageSize = self.profileImage.frame.size
        let popup = STPopupController(rootViewController: vc)
        popup.navigationBar.barTintColor = ChachaTeal
        popup.navigationBar.tintColor = UIColor.whiteColor()
        popup.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        popup.style = STPopupStyle.BottomSheet
        popup.presentInViewController(self)
    }
    
    func setNormalGUI() {
        self.view.layer.addSublayer(setBottomBlur())
        createQuestionBubbleGUI(theQuestionButtonOne)
        createQuestionBubbleGUI(theQuestionButtonTwo)
        createQuestionBubbleGUI(theQuestionButtonThree)
        editOrBackOrSaveButton.layer.cornerRadius = 10
        if let fullName = userOfTheCard?.fullName {
            theFullNameLabel.text = fullName
        }
        if let title = userOfTheCard?.title {
            theTitleLabel.text = title
        }
        if let age = userOfTheCard?.calculateBirthDate() {
            theAgeLabel.text = ", " + "\(age)"
        }
        if let factOne = userOfTheCard?.factOne {
            theFirstBulletText.text = factOne
        }
        if let factTwo = userOfTheCard?.factTwo {
            theSecondBulletText.text = factTwo
        }
        if let factThree = userOfTheCard?.factThree {
            theThirdBulletText.text = factThree
        }
        if questionDetailState == .ProfileViewOnlyMode {
            editOrBackOrSaveButton.setTitle("edit", forState: .Normal)
        }
        if let profileImage = userOfTheCard?.profileImage {
            self.profileImage.file = profileImage
            self.profileImage.loadInBackground()
        } else {
            if anonymousFlowStage(.MainPageFirstVisitHandOverlay) {
                profileImage.image = UIImage(named: "DrivingGirl")
            } else {
                profileImage.backgroundColor = ChachaBombayGrey
                theProfileImageButtonOverlay.setTitle("No Picture", forState: .Normal)
                theProfileImageButtonOverlay.titleLabel?.textAlignment = .Center
            }
        }
        do {
            let question = try userOfTheCard?.questionOne?.fetchIfNeeded()
            if let question = question {
                theQuestionButtonOne.setTitle(question.question, forState: .Normal)
            }
            } catch {
                print("there was an error fetching the question")
            }
        do {
            let question = try userOfTheCard?.questionTwo?.fetchIfNeeded()
            if let question = question {
                theQuestionButtonTwo.setTitle(question.question, forState: .Normal)
            }
        } catch {
            print("there was an error fetching the question")
        }
        do {
            let question = try userOfTheCard?.questionThree?.fetchIfNeeded()
            if let question = question {
                theQuestionButtonThree.setTitle(question.question, forState: .Normal)
            }
        } catch {
            print("there was an error fetching the question")
        }
    }
    
    func setEditingGUI() {
        //to see if any of the textfields have actually been changed.
        theFullNameTextField.addTarget(self, action: #selector(CardDetailViewController.fullNameTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        titleTextField.addTarget(self, action: #selector(CardDetailViewController.titleTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        if let fullName = userOfTheCard?.fullName {
            theFullNameTextField.text = fullName
        }
        if let age = userOfTheCard?.calculateBirthDate() {
            theAgeLabel.text = ", " + "\(age)"
        }
        if let title = userOfTheCard?.title {
            titleTextField.text = title
        }
        theProfileImageButtonOverlay.setImage(UIImage(named: "camera-Colored"), forState: .Normal)
//        theProfileImageButtonOverlay.setTitle("", forState: .Normal)
        self.theFullNameLabel.hidden = true
        self.theFullNameTextField.hidden = false
        self.titleTextField.hidden = false
        theFullNameTextField.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSForegroundColorAttributeName: ChachaTeal])
        theTitleLabel.hidden = true
        theCustomQuestionButton.setTitle("Set Filters", forState: .Normal)
    }
    
    func fullNameTextFieldDidChange(textField: UITextField) {
        fullNameTextFieldDidChange = true
    }
    
    func titleTextFieldDidChange(textField: UITextField) {
        titleTextFieldDidChange = true
    }
    
    
    
    private func setupTapHandler() {
        theProfileImageButtonOverlay.tapped { _ in
            if self.questionDetailState == .OtherUserProfileViewOnlyMode {
                self.dismissViewControllerAnimated(false, completion: nil)
            } else if self.questionDetailState == .EditingMode {
                //put image picker/camera picker here
                self.createBottomPicturePopUp()
            }
        }
        
        theAgeLabel.tapped { _ in
            if self.questionDetailState == .EditingMode {
                DatePickerDialog().show("Your Birthday!", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
                    (birthday) -> Void in
                    let calendar : NSCalendar = NSCalendar.currentCalendar()
                    let now = NSDate()
                    let ageComponents = calendar.components(.Year,
                        fromDate: birthday,
                        toDate: now,
                        options: [])
                    self.theAgeLabel.text = ", " + "\(ageComponents.year)"
                    self.userOfTheCard?.birthDate = birthday
                    self.userOfTheCard?.saveInBackground()
                }
            }
        }
        
            theFirstBulletText.tapped { (_) in
                if self.questionDetailState == .EditingMode {
                    self.createDetailPopUp(Fact.FactOne)
                }
            }
            
            theSecondBulletText.tapped { (_) in
                if self.questionDetailState == .EditingMode {
                    self.createDetailPopUp(Fact.FactTwo)
                }
            }
            
            theThirdBulletText.tapped { (_) in
                if self.questionDetailState == .EditingMode {
                    self.createDetailPopUp(Fact.FactThree)
                }
            }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

//creating hand overlay
extension CardDetailViewController {
    func createHandOverlay() {
        theHandOverlayBackgroundColorView = createBackgroundOverlay()
        self.view.addSubview(theHandOverlayBackgroundColorView)
        theHandOverlayBackgroundColorView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        let theHandImage = createHandImageOverlay()
        theHandOverlayBackgroundColorView.addSubview(theHandImage)
        theHandImage.snp_makeConstraints { (make) in
            make.center.equalTo(theQuestionButtonOne).offset(CGPointMake(20, 60))
        }
        
        let overlayLabel = createLabelForOverlay("Ask Taylor a question!")
        theHandOverlayBackgroundColorView.addSubview(overlayLabel)
        overlayLabel.snp_makeConstraints { (make) in
            make.center.equalTo(profileImage)
        }
    }
    
    func removeHandOverlay() {
        theHandOverlayBackgroundColorView.removeFromSuperview()
    }
    
    func createAnonymousFlow() {
        if PFAnonymousUtils.isLinkedWithUser(User.currentUser()) {
            switch anonymousFlowGlobal {
            case .MainPageFirstVisitHandOverlay: createHandOverlay()
            }
        }
    }
}


protocol PopUpViewControllerDelegate{
    func passFactDescription(text: String, fact: Fact)
}

extension CardDetailViewController: PopUpViewControllerDelegate {
    func passFactDescription(text: String, fact: Fact) {
        switch fact {
        case .FactOne: theFirstBulletText.text = text
        case .FactTwo: theSecondBulletText.text = text
        case .FactThree: theThirdBulletText.text = text
        }
    }
}

protocol QuestionPopUpViewControllerDelegate{
    func passQuestionText(text: String, questionNumber: PopUpQuestionNumber)
}

extension CardDetailViewController: QuestionPopUpViewControllerDelegate {
    func passQuestionText(text: String, questionNumber: PopUpQuestionNumber) {
        switch questionNumber {
        case .QuestionOne: theQuestionButtonOne.setTitle(text, forState: .Normal)
        case .QuestionTwo: theQuestionButtonTwo.setTitle(text, forState: .Normal)
        case .QuestionThree: theQuestionButtonThree.setTitle(text, forState: .Normal)
        case .CustomQuestion: break
        }
    }
}

extension CardDetailViewController: MagicMoveable {
    
    var isMagic: Bool {
        return true
    }
    
    var duration: NSTimeInterval {
        return 1.0
    }
    
    var spring: CGFloat {
        return 1.0
    }
    
    var magicViews: [UIView] {
        return [profileImage]
    }
}

extension CardDetailViewController: BottomPicturePopUpViewControllerDelegate {
    func passImage(image: UIImage) {
        imageWasChanged = true
        profileImage.image = image
    }
}

extension CardDetailViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case LogInPageSegue
        case FilterInputPageSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .FilterInputPageSegue:
            let destinationVC = segue.destinationViewController as! FilterViewController
            destinationVC.filterUserMode = FilterUserMode.UserEditingMode
        default: break
        }
    }
}
