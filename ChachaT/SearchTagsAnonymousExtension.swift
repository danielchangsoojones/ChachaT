//
//  SearchTagsAnonymousExtenson.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/7/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

extension SearchTagsViewController {
    func anonymousUserSetup() {
        if AnonymousDataStore().isUserAnonymous {
            createSignUpButton()
        }
    }
    
    //TODO: the sign up button needs to move as keyboard gets shown
    fileprivate func createSignUpButton() {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setCornerRadius(radius: 10)
        button.backgroundColor = CustomColors.JellyTeal
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(segueToSignUpPage), for: .allEvents)
        self.view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.bottom.trailing.equalToSuperview().inset(10)
        }
    }
    
    func segueToSignUpPage() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpLogInViewController") as! SignUpLogInViewController
        presentVC(signUpVC)
    }
    
    
}
