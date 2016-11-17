//
//  ChachaNavigationViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/25/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

class ChachaNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barTintColor = UIColor.white //makes the background of the navbar a certain color
        navigationBar.tintColor = CustomColors.JellyTeal //makes the back button a certain color
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //when we push a new view controller, we want to have a a custom back button. 
        //To set the back item for a View Controller, you need to set the back item in the previous ViewController, hence why I am setting it here. YOu can't set it in the destinationVC or it is too late
        //This allows us to have the same backButton throughout the app
        if viewControllers.count >= 1 {
            let pushingVC = viewControllers[viewControllers.count - 1]
            let backItem = UIBarButtonItem()
            backItem.title = "" //get rid of the title, we just want the back arrow: <
            pushingVC.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        }
        super.pushViewController(viewController, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
