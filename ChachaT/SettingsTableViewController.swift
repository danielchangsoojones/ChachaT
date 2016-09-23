//
//  SettingsTableViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/13/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EFTools

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SettingsTableViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case OnboardingPageSegue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case .OnboardingPageSegue:
            User.logOut()
        }
    }
}
