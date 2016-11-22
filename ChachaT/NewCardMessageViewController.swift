//
//  NewCardMessageViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/16/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EZSwiftExtensions

protocol NewCardMessageControllerDelegate {
    func removeMessageFromSwipe()
}

class NewCardMessageViewController: UIViewController {
    var cardMessageView: NewCardMessageView!
    var swipe: Swipe!
    
    //need to hold in global variable
    var chatVC: ChatViewController?
    var delegate: NewCardMessageControllerDelegate?
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
        segueToChatVC(swipe: swipe)
        deleteMessage(swipe: swipe)
    }
    
    fileprivate func segueToChatVC(swipe: Swipe) {
        chatVC = ChatViewController.instantiate(otherUser: swipe.otherUser)
        //original swipe was a reference to the original swipe, and we want to pass it to the swipe with the incoming swipe message, even though it gets deleted here. 
        let swipeCopy = Swipe(otherUser: swipe.otherUser, otherUserApproval: swipe.otherUserApproval, parseSwipe: swipe.parseSwipe)
        swipeCopy.incomingMessage = swipe.incomingMessage
        chatVC?.starterSwipe = swipeCopy
        if let navController = self.parent?.navigationController {
            navController.pushViewController(chatVC!, animated: true)
        } else {
            let navController = ChachaNavigationViewController(rootViewController: chatVC!)
            self.present(navController, animated: true, completion: {
                //TODO: make this show the normal back button indicator we have on every other page, just can't exactly figure out how to at the moment. 
                self.chatVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.dismissChatVC))
            })
        }
        
    }
    
    @objc func dismissChatVC() {
        chatVC?.dismiss(animated: true, completion: nil)
    }
    
    func showMessage() {
        if let parentVC = self.parent {
            self.view.frame = parentVC.view.bounds
            cardMessageView.animateShowingMessage()
        }
    }
    
    func removeSelf() {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        swipe.incomingMessage = nil
        delegate?.removeMessageFromSwipe()
    }
    
    
}
