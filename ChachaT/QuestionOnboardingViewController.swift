//
//  QuestionOnboardingViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 6/6/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class QuestionOnboardingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let sampleQuestionsArray : [String] = ["What would the person who named Walkie Talkies have named other items?", "What is something someone said that forever changed your way of thinking?", "What G-Rated Joke Always Cracks You Up?", "What is your favorite fun fact?", "Who is the scariest person you have ever met?","What will be the \"turns out cigarettes are bad for us.\" of our generation?", "What was a loophole that you found and exploited the hell out of?", "What was your \"I don't get paid enough for this shit\" moment?"]
    var index : Int?
    var questionNumber: PopUpQuestionNumber = .QuestionOne

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//tableView Delegate Methods
extension QuestionOnboardingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleQuestionsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.QuestionOnboardingCell.rawValue)! as! QuestionOnboardingTableViewCell
        let index = indexPath.item
        let questionString = sampleQuestionsArray[index]
        cell.index = index
        cell.delegate = self
        cell.backgroundColor = UIColor.clearColor()
        cell.popUpQuestionNumber = self.questionNumber
        cell.theQuestionButton.setTitle(questionString, forState: .Normal)
        return cell
    }
}

protocol QuestionOnboardingTableViewCellDelegate {
    func createQuestionPopUp(questionNumber: PopUpQuestionNumber)
    func passIndexForButtonPushed(index: Int, questionNumber: PopUpQuestionNumber)
}

extension QuestionOnboardingViewController: QuestionOnboardingTableViewCellDelegate {
    func createQuestionPopUp(questionNumber: PopUpQuestionNumber) {
        //look at STPopUp github for more info.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("UserDetailQuestionPopUpViewController") as! QuestionPopUpViewController
        vc.popUpQuestionNumber = questionNumber
        let question = Question()
        question.question = sampleQuestionsArray[index!]
        switch questionNumber {
        case .QuestionOne: vc.currentQuestion = question
        case .QuestionTwo: vc.currentQuestion = question
        case .QuestionThree: vc.currentQuestion = question
        case .CustomQuestion: break
        }
        vc.questionPopUpState = .EditingMode
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func passIndexForButtonPushed(index: Int, questionNumber: PopUpQuestionNumber) {
        self.index = index
        switch questionNumber {
        case .QuestionOne: self.questionNumber = .QuestionTwo
        case .QuestionTwo: self.questionNumber = .QuestionThree
        case .QuestionThree: break
        case .CustomQuestion: break
        }
    }
}

