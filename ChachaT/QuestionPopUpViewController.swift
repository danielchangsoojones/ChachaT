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
    @IBOutlet weak var theMainPageButton: UIButton!
    
    let sampleQuestionsArray : [String] = ["What would the person who named Walkie Talkies have named other items?", "What is something someone said that forever changed your way of thinking?", "What G-Rated Joke Always Cracks You Up?", "What is your favorite fun fact?", "Who is the scariest person you have ever met?","What will be the \"turns out cigarettes are bad for us.\" of our generation?", "What was a loophole that you found and exploited the hell out of?", "What was your \"I don't get paid enough for this shit\" moment?"]
    
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
        case .QuestionOne:
            currentUser!.questionOne = currentQuestion
            popUpQuestionNumber = .QuestionTwo
        case .QuestionTwo:
            currentUser!.questionTwo = currentQuestion
            popUpQuestionNumber = .QuestionThree
        case .QuestionThree:
            currentUser!.questionThree = currentQuestion
            popUpQuestionNumber = .CustomQuestion
        case .CustomQuestion: break
        }
        theActivitySpinner.hidden = false
        theActivitySpinner.startAnimating()
        let array : [PFObject] = [currentUser!, currentQuestion!]
        PFObject.saveAllInBackground(array) { (success, error) in
            if success {
                //for when we are in onboarding mode and answer the 3rd question.
                if self.fromOnboarding {
                    if self.popUpQuestionNumber == .CustomQuestion {
                        //the new user has answered 3 questions, so can go to the filter page.
                        self.performSegueWithIdentifier(.FilteringPageSegue, sender: self)
                    } else {
                        self.setRandomSampleQuestion()
                    }
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
        if self.navigationController == nil {
            
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save))
        self.edgesForExtendedLayout = UIRectEdge.None
        theLikeButton.hidden = true
        theMainPageButton.hidden = true
        setRandomSampleQuestion()
    }
    
    func setUnwrittenQuestionGUI() {
        if questionPopUpState == .EditingMode {
            theAnswerTextField.userInteractionEnabled = true
            theQuestionTextField.userInteractionEnabled = true
        } else if questionPopUpState == .ViewOnlyMode {
            theQuestionTextField.text = "Oops, they don't seem to have written a question yet"
        }
    }
    
    func setRandomSampleQuestion() {
        if fromOnboarding {
            let randomIndex = Int(arc4random_uniform(UInt32(sampleQuestionsArray.count)))
            self.theQuestionTextField.text = self.sampleQuestionsArray[randomIndex]
            self.theAnswerTextField.text = ""
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
        let theHandImage = createHandImageOverlay()
        let overlayLabel = createLabelForOverlay("Like Taylor's Question")
        createSemiTranslucentBlackOverlay([theHandImage, overlayLabel])
        theHandImage.snp_makeConstraints { (make) in
            make.center.equalTo(theLikeButton).offset(CGPointMake(30, 60))
        }
        overlayLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(theLikeButton)
            make.left.equalTo(theLikeButton).offset(50)
        }
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
        default: break
        }
    }
}

