//
//  MatchNotificationViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/2/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class MatchNotificationViewController: UIViewController {
    @IBOutlet weak var theButtonStackView: UIStackView!
    @IBOutlet weak var theUsersStackView: UIStackView!
    
    var currentUser: User = User.current()!
    var otherUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonStackViewSetup()
        userAreaSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//button extension
extension MatchNotificationViewController {
    //button actions
    func returnToSwiping(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func startAMessage(_ button: UIButton) {
        //need to hold the navigationVC outside of the dismiss completion, because by the time the dimsiss begins, the navigationVC is nil.
        let chachaNavigationVC = self.presentingViewController as! ChachaNavigationViewController
        self.dismiss(animated: false) {
            //after we dismiss this VC, we want to go straight to the messaging page, but when we go back from the messaging page. This matches notification page will have been deleted, and it will just take us right back to the swiping page!
            let chatVC = ChatViewController()
            chatVC.currentUser = User.current()
            chatVC.otherUser = User.current()!
            chachaNavigationVC.pushViewController(chatVC, animated: false)
        }
    }
    
    func buttonStackViewSetup() {
        makeButton(title: "Message", action: #selector(MatchNotificationViewController.startAMessage(_:)))
        makeButton(title: "Keep Shuffling", action: #selector(MatchNotificationViewController.returnToSwiping(_:)))
    }
    
    func makeButton(title: String, action: Selector) {
        let button = UIButton()
        button.setTitle(title, for: UIControlState())
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 30)
        button.addTarget(self, action: action, for: .touchDown)
        button.backgroundColor = CustomColors.JellyTeal
        button.setCornerRadius(radius: 25)
        theButtonStackView.addArrangedSubview(button)
        button.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
    }
}

extension MatchNotificationViewController {
    func userAreaSetup() {
        //TODO: should just be passing the images, so they appear right away, because right now, it loads the photos.
        userCircleSetup(name: currentUser.fullName ?? "", imageFile: currentUser.profileImage ?? nil, stackViewIndex: 0)
        userCircleSetup(name: otherUser.fullName ?? "", imageFile: otherUser.profileImage ?? nil, stackViewIndex: 2)
    }
    
    func userCircleSetup(name: String, imageFile: AnyObject?, stackViewIndex: Int) {
        let profileView = CircleProfileView(frame: CGRect(x: 0, y: 0, w: ez.screenWidth * 0.33, h: 150), name: name, imageFile: imageFile)
        profileView.setLabelColor(color: UIColor.white)
        theUsersStackView.insertArrangedSubview(profileView, at: stackViewIndex)
    }
}
