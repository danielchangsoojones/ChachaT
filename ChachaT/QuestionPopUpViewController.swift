//
//  QuestionPopUpViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/25/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class QuestionPopUpViewController: UIViewController {

    @IBOutlet weak var theQuestionTextField: UITextView!
    @IBOutlet weak var theAnswerTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setInitialGUI()
    }
    
    func setInitialGUI() {
        theQuestionTextField.textColor = placeHolderTextColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension QuestionPopUpViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        editingBeginsTextView(textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        editingEndedTextView(textView, placeHolderText: "hi")
    }
}
