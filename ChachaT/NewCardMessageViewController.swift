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
    
    var dataStore: NewCardMessageDataStore = NewCardMessageDataStore()

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
        dataStore.deleteSwipeMessage(swipe: swipe)
    }
    
    func respondToMessage(swipe: Swipe) {
        deleteMessage(swipe: swipe)
        segueToChatVC(swipe: swipe)
    }
    
    fileprivate func segueToChatVC(swipe: Swipe) {
        let chatVC = ChatViewController.instantiate(otherUser: swipe.otherUser)
        chatVC.starterSwipe = swipe
        //TODO: what if the navigation controller doesn't exist
        if let navController = self.parent?.navigationController {
            navController.pushViewController(chatVC, animated: true)
        } else {
            //TODO: I just want to be able to segue right to the chat page and have a back button that the user can use to go back to the card detail page. But, I haven't figured out a simple way, since the card detail is not in a navigation controller. So, this is a temporary fix where it goes to main page and then pushes the chat page until I can figure out a way to do this.
            let chachaNavigationVC = self.presentingViewController as! ChachaNavigationViewController
            self.dismiss(animated: false) {
                //after we dismiss this VC, we want to go straight to the messaging page, but when we go back from the messaging page. This card detail page will have been deleted, and it will just take us right back to the swiping page
                chachaNavigationVC.pushViewController(chatVC, animated: true)
            }
        }
        
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
