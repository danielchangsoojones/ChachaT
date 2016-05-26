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

enum QuestionPopUpState {
    case EditingMode
    case ViewOnlyMode
}

class QuestionPopUpViewController: PopUpSuperViewController {

    @IBOutlet weak var theQuestionTextField: UITextView!
    @IBOutlet weak var theAnswerTextField: UITextView!
    @IBOutlet weak var theSaveButton: UIButton!
    @IBOutlet weak var theBottomBarView: UIView!
    @IBOutlet weak var theBottomStackView: UIStackView!
    @IBOutlet weak var theClearButton: UIButton!
    @IBOutlet weak var theBackgroundColorView: UIView!
    @IBOutlet weak var theBottomBackgroundColorConstraint: NSLayoutConstraint!
    
    var currentQuestion: Question?
    var questionNumber: Int = 1
    var theQuestionTextFieldChanged = false
    var theAnswerTextFieldChanged = false
    
    var questionPopUpState = QuestionPopUpState.ViewOnlyMode
    
    var delegate: QuestionPopUpViewControllerDelegate?
    
    @IBAction func clearCurrentTextField(sender: AnyObject) {
        activeTextField.text = nil
        activeTextField.becomeFirstResponder()
    }
    
    @IBAction func save(sender: AnyObject) {
        theSaveButton.enabled = false
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
        switch questionNumber {
        case 1: currentUser!.questionOne = currentQuestion
        case 2: currentUser!.questionTwo = currentQuestion
        case 3: currentUser!.questionThree = currentQuestion
        default: break
        }
        theActivitySpinner.hidden = false
        theActivitySpinner.startAnimating()
        let array : [PFObject] = [currentUser!, currentQuestion!]
        PFObject.saveAllInBackground(array) { (success, error) in
            if success {
                self.delegate?.passQuestionText(self.theQuestionTextField.text, questionNumber: self.questionNumber)
                self.dismissViewControllerAnimated(true, completion: nil)
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
        // Do any additional setup after loading the view.
        if let currentQuestion = currentQuestion {
            theQuestionTextField.text = currentQuestion.question
            theAnswerTextField.text = currentQuestion.topAnswer
            if questionPopUpState == .ViewOnlyMode {
                setViewOnlyGUI(currentQuestion)
            } else if questionPopUpState == .EditingMode {
                setEditingGUI(currentQuestion)
            }
        } else {
            setUnwrittenQuestionGUI()
        }
        
    }
    
    func setViewOnlyGUI(currentQuestion: Question) {
        theBottomBarView.hidden = true
        theBottomStackView.hidden = true
        //made this constraint inactive, so I could rebuild it in the updateViewConstraints without run-time constraint warnings. 
        theBottomBackgroundColorConstraint.active = false
    }
    
    func setEditingGUI(currentQuestion: Question) {
        theQuestionTextField.userInteractionEnabled = false
        theAnswerTextField.userInteractionEnabled = false
    }
    
    override func updateViewConstraints() {
        theBackgroundColorView.snp_updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        super.updateViewConstraints()
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
            placeHolderText = "Your interesting (hopefully not too vulgar) answer"
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