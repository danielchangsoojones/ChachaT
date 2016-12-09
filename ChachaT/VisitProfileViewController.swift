//
//  VisitProfileViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/8/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class VisitProfileViewController: UIViewController {
    var checkProfileView: CheckProfileView!
    var swipe: Swipe? {
        didSet {
            userOfCard = swipe?.otherUser
        }
    }
    var userOfCard: User? {
        didSet {
            viewSetup()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewSetup() {
        let navBarHeight = ez.screenStatusBarHeight + navigationBarHeight
        let boundsWithoutNavBar = CGRect(x: 0, y: navBarHeight, w: self.view.bounds.width, h: self.view.bounds.height - navBarHeight)
        checkProfileView = CheckProfileView(frame: boundsWithoutNavBar)
        if let user = userOfCard, let cardView = checkProfileView.theCardView {
            cardView.userOfTheCard = userOfCard
            CardDetailViewController.addAsChildVC(to: self,toView: cardView.theVertSlideView.theBumbleDetailView, user: user)
        }
        if navigationController == nil {
            checkProfileView.addBackButton(target: self, selector: #selector(backButtonPressed))
        }
        
        
        self.view.addSubview(checkProfileView)
    }
    
    func backButtonPressed() {
       dismiss(animated: true, completion: nil)
    }
}

extension VisitProfileViewController: MagicMoveable {
    var isMagic: Bool {
        return true
    }
    
    var duration: TimeInterval {
        return 0.7
    }
    
    var spring: CGFloat {
        return 1.0
    }
    
    var magicViews: [UIView] {
        return [checkProfileView.theCardView.theVertSlideView.theBumbleScrollView]
    }
}
