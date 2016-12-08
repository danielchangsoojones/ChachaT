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
    func setUpSearchNavigationBar(_ viewController: UIViewController) {
        if let _ = viewController.navigationController as? ChachaNavigationViewController {
            viewController.navigationItem.hidesBackButton = true
        }
    }
    
    override func perform() {
        //we don't want to alter these global variables, so we set them in holder variables
        let sourceVC = self.source as! BackgroundAnimationViewController
        let destinationVC = self.destination as! SearchTagsViewController
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            }) { (finished) in
                
                let time = DispatchTime.now() + Double(Int64(0.001 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                
                DispatchQueue.main.asyncAfter(deadline: time) {
                    //need to set tiny timer, because if I add and remove a view at the same time, then I will get an unbalanced call error.
                    //this is a hacky way of fixing that by just offsetting the time of adding it by .001 seconds
                    
                    sourceVC.navigationController?.pushViewController(destinationVC, animated: false)
                    self.setUpSearchNavigationBar(destinationVC)
                }
        }
    }
}








