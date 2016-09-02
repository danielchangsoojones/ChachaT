//
//  CustomBackgroundAnimationToSearchSegue.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/29/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

class CustomBackgroundAnimationToSearchSegue: UIStoryboardSegue {
    
//    func hideTinderSubviews(hide: Bool, viewController: BackgroundAnimationViewController) {
//        //TODO: add in approve/skip button, it hides them both when we make one hidden.
//        let tinderSubviewsArray : [UIView] = [viewController.theMessageButton, viewController.theProfileButton, viewController.kolodaView]
//        for subviews in tinderSubviewsArray {
//            subviews.hidden = hide
//        }
//    }
//
//    //Purpose: For showing/unshowing the search bar in navigation bar in the background animationview controller
//    func hideNavigationControllerComponents(hideSubviews: Bool, viewController: BackgroundAnimationViewController) {
//        if let chachaNavigationViewController = viewController.navigationController! as? ChachaNavigationViewController {
//            viewController.navigationItem.rightBarButtonItem = hideSubviews ? nil : viewController.rightNavigationButton
//            viewController.navigationItem.leftBarButtonItem = hideSubviews ? nil : viewController.leftNavigationButton
//            chachaNavigationViewController.navigationBarLogo.hidden = hideSubviews
//            hideTinderSubviews(hideSubviews, viewController: viewController)
//            showSearchBox(chachaNavigationViewController)
//        }
//    }
    
    func setUpSearchNavigationBar(viewController: UIViewController) {
        if let chachaNavigationVC = viewController.navigationController as? ChachaNavigationViewController {
            viewController.navigationItem.hidesBackButton = true
//            chachaNavigationVC.navigationBarLogo.hidden = true
        }
    }
    
    override func perform() {
        //we don't want to alter these global variables, so we set them in holder variables
        let sourceVC = self.sourceViewController as! BackgroundAnimationViewController
        let destinationVC = self.destinationViewController as! SearchTagsViewController
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            }) { (finished) in
                
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.001 * Double(NSEC_PER_SEC)))
                
                dispatch_after(time, dispatch_get_main_queue()) {
                    //need to set tiny timer, because if I add and remove a view at the same time, then I will get an unbalanced call error.
                    //this is a hacky way of fixing that by just offsetting the time of adding it by .001 seconds
                    
                    sourceVC.navigationController?.pushViewController(destinationVC, animated: false)
                    self.setUpSearchNavigationBar(destinationVC)
                }
        }
    }
}








