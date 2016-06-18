//
//  QuestionPopUpViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/25/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse
import SnapKit
import EFTools
import DOFavoriteButton

enum QuestionPopUpState {
    case EditingMode
    case ViewOnlyMode
}

enum PopUpQuestionNumber {
    case QuestionOne
    case QuestionTwo
    case QuestionThree
    case CustomQuestion
}

class QuestionPopUpViewController: PopUpSuperViewController {

    @IBOutlet weak var theQuestionTextField: UITextView!
    @IBOutlet weak var theAnswerTextField: UITextView!
    @IBOutlet weak var theBackgroundColorView: UIView!
    @IBOutlet weak var theLikeButton: DOFavoriteButton!
    var theHandOverlayBackgroundColorView: UIView = UIView()
    
    var currentQuestion: Question?
    var popUpQuestionNumber: PopUpQuestionNumber = .QuestionOne
    var theQuestionTextFieldChanged = false
    var theAnswerTextFieldChanged = false
    
    var fromOnboarding = false
    
    var questionPopUpState = QuestionPopUpState.ViewOnlyMode
    
    var delegate: QuestionPopUpViewControllerDelegate?
    
    func save() {
        self.navigationItem.leftBarButtonItem?.enabled = false
        let currentUser = User.currentUser()
        //if the currentQuestion was passed to the pop up, as opposed to making a new question
        if let currentQuestion = currentQuestion {
            if theQuestionTextFieldChanged {
                currentQuestion.question = theQuestionTextField.text
            }
            if theAnswerTextFieldChanged {
                currentQuestion.topAnswer = theAnswerTextField.text
            }
        } else {
            currentQuestion = Question()
            currentQuestion?.createdBy = currentUser
            currentQuestion?.question = theQuestionTextField.text
            currentQuestion?.topAnswer = theAnswerTextField.text
        }
        switch popUpQuestionNumber {
        case .QuestionOne: currentUser!.questionOne = currentQuestion
        case .QuestionTwo: currentUser!.questionTwo = currentQuestion
        case .QuestionThree: currentUser!.questionThree = currentQuestion
        case .CustomQuestion: break
        }
        theActivitySpinner.hidden = false
        theActivitySpinner.startAnimating()
        let array : [PFObject] = [currentUser!, currentQuestion!]
        PFObject.saveAllInBackground(array) { (success, error) in
            if success {
                //for when we are in onboarding mode and answer the 3rd question.
                if self.fromOnboarding && self.popUpQuestionNumber == .QuestionThree {
                    self.performSegueWithIdentifier(.FilteringPageSegue, sender: self)
                } else {
                    //all the other times, I can just pop the view controller. 
                    self.delegate?.passQuestionText(self.theQuestionTextField.text, questionNumber: self.popUpQuestionNumber)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapHandler()
        createAnonymousFlow()
        contentSizeInPopup = CGSizeMake(self.view.bounds.width - 75, self.view.bounds.height - 100)
        setNormalGUI()
        if questionPopUpState == .EditingMode {
            setEditingGUI()
        }
        // Do any additional setup after loading the view.
        if let currentQuestion = currentQuestion {
            theQuestionTextField.text = currentQuestion.question
            theAnswerTextField.text = currentQuestion.topAnswer
        } else {
            setUnwrittenQuestionGUI()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        animateOverlay(theHandOverlayBackgroundColorView)
    }
    
    func setNormalGUI() {
        theQuestionTextField.layer.cornerRadius = 10.0
        theAnswerTextField.layer.cornerRadius = 10.0
        //tagging the fields, so we know which textfield was used. Will be used in the text view delegate methods.
        theQuestionTextField.tag = 1
        theAnswerTextField.tag = 2
        //create shadow for the question Text fields
        theQuestionTextField.layer.shadowColor = UIColor.whiteColor().CGColor
        theQuestionTextField.layer.shadowRadius = 3.0;
        theQuestionTextField.layer.shadowOpacity = 1;
        theQuestionTextField.layer.shadowOffset = CGSizeZero;
    }
    
    private func setupTapHandler() {
        theLikeButton.tapped { (_) in
            self.likeTapped(self.theLikeButton)
            if anonymousFlowStage(.MainPageFirstVisitMatchingPhase) {
                let alert = Alert(closeButtonHidden: true)
                alert.addButton("Gotcha") {
                    //Todo: should lead to the messaging page with the matched person
                    self.performSegueWithIdentifier(.QuestionPageToMainTinderPageSegue, sender: self)
                }
                alert.createAlert("It's A Match!", subtitle: "A match is when you and Taylor like each other's answers. Then, the two of you could message. I just haven't built a messaging page yet.", closeButtonTitle: "Okay", type: .Success)
            }
        }
    }
    
    func likeTapped(sender: DOFavoriteButton) {
        if sender.selected {
            // deselect
            sender.deselect()
        } else {
            // select with animation
            sender.select()
        }
    }
    
    func setEditingGUI() {
        theQuestionTextField.userInteractionEnabled = true
        theAnswerTextField.userInteractionEnabled = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save))
        self.edgesForExtendedLayout = UIRectEdge.None
    }
    
    func setUnwrittenQuestionGUI() {
        theQuestionTextField.textColor = placeHolderTextColor
        theAnswerTextField.textColor = placeHolderTextColor
        if questionPopUpState == .EditingMode {
            theAnswerTextField.userInteractionEnabled = true
            theQuestionTextField.userInteractionEnabled = true
        } else if questionPopUpState == .ViewOnlyMode {
            theQuestionTextField.text = "Oops, they don't seem to have written a question yet"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//creating hand overlay
extension QuestionPopUpViewController {
    func createHandOverlay() {
        theHandOverlayBackgroundColorView = createBackgroundOverlay()
        self.view.addSubview(theHandOverlayBackgroundColorView)
        theHandOverlayBackgroundColorView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        let theHandImage = createHandImageOverlay()
        theHandOverlayBackgroundColorView.addSubview(theHandImage)
        theHandImage.snp_makeConstraints { (make) in
            make.center.equalTo(theLikeButton).offset(CGPointMake(30, 60))
        }
        
        let overlayLabel = createLabelForOverlay("Like Taylor's Question")
        theHandOverlayBackgroundColorView.addSubview(overlayLabel)
        overlayLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(theLikeButton)
            make.left.equalTo(theLikeButton).offset(50)
        }
    }
    
    func removeHandOverlay() {
        theHandOverlayBackgroundColorView.removeFromSuperview()
    }
    
    func createAnonymousFlow() {
        if PFAnonymousUtils.isLinkedWithUser(User.currentUser()) {
            switch anonymousFlowGlobal {
            case .MainPageFirstVisitMatchingPhase: createHandOverlay()
            case .MainPageSecondVisitFilteringStage: break
            case .MainPageThirdVisitSignUpPhase: break
            }
        }
    }
}

extension QuestionPopUpViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        activeTextField = textView
        editingBeginsTextView(textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.tag == 1 {
            placeHolderText = "A question about you (e.g. what is your favorite quote?). Remember to write it like someone else is asking you..."
        } else if textView.tag == 2 {
            placeHolderText = "Your interesting (hopefully not too obscene) answer"
        }
        editingEndedTextView(textView, placeHolderText: placeHolderText)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.tag == 1 {
            theQuestionTextFieldChanged = true
        } else if textView.tag == 2 {
            theAnswerTextFieldChanged = true
        }
    }
}

extension QuestionPopUpViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case FilteringPageSegue
        case QuestionPageToMainTinderPageSegue
        case MainPageButtonToMainPageSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .FilteringPageSegue:
            let destinationVC = segue.destinationViewController as! FilterViewController
            destinationVC.filterUserMode = FilterUserMode.UserEditingMode
            destinationVC.fromOnboarding = true
        case .QuestionPageToMainTinderPageSegue:
            if anonymousFlowStage(.MainPageFirstVisitMatchingPhase) {
                anonymousFlowGlobal = .MainPageSecondVisitFilteringStage
            }
        default: break
        }
    }
}

