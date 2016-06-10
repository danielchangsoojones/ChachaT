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
        contentSizeInPopup = CGSizeMake(self.view.bounds.width - 75, self.view.bounds.height - 100)
        theQuestionTextField.layer.cornerRadius = 10.0
        theAnswerTextField.layer.cornerRadius = 10.0
        theQuestionTextField.tag = 1
        theAnswerTextField.tag = 2
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .FilteringPageSegue:
            let destinationVC = segue.destinationViewController as! FilterViewController
            destinationVC.filterUserMode = FilterUserMode.UserEditingMode
            destinationVC.fromOnboarding = true
        }
    }
}

