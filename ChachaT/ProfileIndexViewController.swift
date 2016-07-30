//
//  ProfileIndexViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/4/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EFTools

class ProfileIndexViewController: UIViewController {

    @IBAction func addingTagsToProfileButtonPressed(sender: UIButton) {
        performSegueWithIdentifier(.AddingTagsToProfileSegue, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ProfileIndexViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case AddingTagsToProfileSegue
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        switch segueIdentifierForSegue(segue) {
//    }
}


