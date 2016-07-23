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

    @IBOutlet weak var theButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchesQuery()
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
                    self.theButton.setTitle(match.targetUser.fullName, forState: .Normal)
                }
            } else {
                print(error)
            }
        })
    }

}
