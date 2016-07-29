//
//  BackgroundAnimationFilteringExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

extension BackgroundAnimationViewController {
    //Purpose: For showing/unshowing the search bar in navigation bar
    func hideNavigationControllerComponents(hideSubviews: Bool) {
        if let chachaNavigationViewController = self.navigationController! as? ChachaNavigationViewController {
            self.navigationItem.rightBarButtonItem = hideSubviews ? nil : rightNavigationButton
            self.navigationItem.leftBarButtonItem = hideSubviews ? nil : leftNavigationButton
            chachaNavigationViewController.navigationBarLogo.hidden = hideSubviews
            hideTinderSubviews(hideSubviews)
        }
    }
    
    func hideTinderSubviews(hide: Bool) {
        //TODO: add in approve/skip button, it hides them both when we make one hidden.
        let tinderSubviewsArray : [UIView] = [theMessageButton, theProfileButton, kolodaView]
        for subviews in tinderSubviewsArray {
            subviews.hidden = hide
        }
    }
}
