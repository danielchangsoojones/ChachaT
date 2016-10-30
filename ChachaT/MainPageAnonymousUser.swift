//
//  MainPageAnonymousUser.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/30/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

extension BackgroundAnimationViewController {
    func anonymousUserSetup() {
        let anonymousDataStore = AnonymousDataStore()
        if anonymousDataStore.isUserAnonymous {
            convertLeftNavigationButtonToSignUpButton()
        }
    }
    
    fileprivate func convertLeftNavigationButtonToSignUpButton() {
        let leftButton: UIButton = fakeNavigationBar.leftMenuButton
    
        //get rid of the previous target action, and also get rid of the previous image
        leftButton.removeTarget(fakeNavigationBar, action: nil, for: UIControlEvents.allEvents)
        leftButton.setImage(nil, for: .normal)
        
        //set a new title, and action for the button
        leftButton.setTitle("Sign Up", for: .normal)
        leftButton.setTitleColor(CustomColors.JellyTeal, for: .normal)
        leftButton.addTarget(self, action: #selector(segueToOnboardingPage), for: .allEvents)
    }
    
    //For some reason, using #selector makes you use this @objc label on the actual action function
    @objc fileprivate func segueToOnboardingPage() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let onboardingVC = storyboard.instantiateViewController(withIdentifier: "SignUpLogInViewController") as! SignUpLogInViewController
        presentVC(onboardingVC)
    }
}
