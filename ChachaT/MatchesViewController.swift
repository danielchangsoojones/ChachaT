//
//  MatchesViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/23/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController {
    private struct MatchesConstants {
        static let numberOfSections : Int = 2
    }
    
    
    @IBOutlet weak var theTableView: UITableView!
    var matchArray : [Match] = []
    
    //go to messages page
    @IBAction func theButtonPressed(sender: UIButton) {
        if !matchArray.isEmpty {
            let match = matchArray[0]
            let chatVC = ChatViewController()
            chatVC.currentUser = User.currentUser()
            chatVC.otherUser = match.targetUser
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func matchesQuery() {
        // query on DateMatch
        let query = Match.query()
        // where currentUser is DateUser.currentUser()! and mutualMatch is true
        query!.whereKey(Constants.currentUser, equalTo: User.currentUser()!)
        query!.whereKey(Constants.mutualMatch, equalTo: true)
        // include targetUser key
        query!.includeKey(Constants.targetUser)
        query?.findObjectsInBackgroundWithBlock({ (matches, error) in
            if error == nil {
                for match in matches as! [Match] {
                    self.matchArray.append(match)
                }
            } else {
                print(error)
            }
        })
    }

}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //the matches area
            return 1
        }
        return 100
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return MatchesConstants.numberOfSections
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, w: 300, h: 300))
        view.backgroundColor = UIColor.yellowColor()
        return view
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentRow = indexPath.row
        let currentSection = indexPath.section
        if currentSection == 0 {
            //the matches area
            let matchesCell = ScrollingMatchesTableViewCell()
            return matchesCell
        }
        let cell = UITableViewCell()
        cell.textLabel?.text = currentRow.toString
    
        return cell
    }
    

}
