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
    let sampleQuestionsArray : [String] = ["what was the scariest moment of your life?"]

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
        return cell
    }

}

