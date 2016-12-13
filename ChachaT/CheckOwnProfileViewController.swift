//
//  CheckOwnProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/8/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class CheckOwnProfileViewController: VisitProfileViewController {
    override func viewDidLoad() {
        userOfCard = User.current()!
        super.viewDidLoad()
        self.title = "Your Profile"
        createBarButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//nav bar buttons
extension CheckOwnProfileViewController {
    func createBarButtons() {
        createRightBarButtonItem()
    }
    
    fileprivate func createRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed(sender:)))
    }
    
    func editPressed(sender: UIBarButtonItem) {
        let editProfileVC = EditProfileViewController.instantiate()
        pushVC(editProfileVC)
    }
}
