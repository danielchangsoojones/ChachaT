//
//  CheckOwnProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/8/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class CheckOwnProfileViewController: UIViewController {
    var userOfCard: User? = User.current()! {
        didSet {
            viewSetup()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        self.title = "Your Profile"
        if userOfCard == User.current()! {
            viewSetup()
        }
        createBarButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewSetup() {
        let navBarHeight = ez.screenStatusBarHeight + navigationBarHeight
        let boundsWithoutNavBar = CGRect(x: 0, y: navBarHeight, w: self.view.bounds.width, h: self.view.bounds.height - navBarHeight)
        let checkProfileView = CheckProfileView(frame: boundsWithoutNavBar)
        if let user = userOfCard, let cardView = checkProfileView.theCardView {
            cardView.userOfTheCard = userOfCard
            CardDetailViewController.addAsChildVC(to: self,toView: cardView.theVertSlideView.theBumbleDetailView, user: user)
        }
        self.view.addSubview(checkProfileView)
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
