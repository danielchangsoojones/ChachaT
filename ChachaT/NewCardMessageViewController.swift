//
//  NewCardMessageViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/16/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class NewCardMessageViewController: UIViewController {
    
    var cardMessageView: NewCardMessageView!
    var swipe: Swipe!

    override func viewDidLoad() {
        super.viewDidLoad()
        setFrame(frame: CGRect(x: 0, y: 0, w: ez.screenWidth, h: 100))
        self.view.translatesAutoresizingMaskIntoConstraints = false //not sure what this does, but makes growing animation happen smoothly
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFrame(frame: CGRect) {
        self.view.frame = frame
        addCardMessageView(frame: frame)
    }
    
    func addCardMessageView(frame: CGRect) {
        //just having a test swipe
        let swipe = Swipe(otherUser: User.current()!, otherUserApproval: false)
        cardMessageView = NewCardMessageView(frame: self.view.bounds, delegate: self, swipe: swipe)
        self.view.addSubview(cardMessageView)
        cardMessageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

extension NewCardMessageViewController: NewCardMessageDelegate {
    func deleteMessage(swipe: Swipe) {
        removeSelf()
        print("implement the delete message func")
    }
    
    func respondToMessage(swipe: Swipe) {
        removeSelf()
        print("implement the respond func")
    }
    
    func showMessage() {
        if let parentVC = self.parent {
            self.view.frame = parentVC.view.bounds
            cardMessageView.animateShowingMessage()
        }
    }
    
    fileprivate func removeSelf() {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    
}
