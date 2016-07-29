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
        if hideSubviews {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            if let chachaNavigationViewController = self.navigationController! as? ChachaNavigationViewController {
                chachaNavigationViewController.navigationBarLogo.hidden = true
            }
        }
    }
}
