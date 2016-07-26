//
//  PageMainViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/24/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Pages
import EFTools

class PageMainViewController: PagesController {
    
    var lockPaging = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let backgroundAnimationNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("BackgroundAnimationNavigationViewController") as! UINavigationController
        let backgroundAnimationRootViewController = backgroundAnimationNavigationController.viewControllers[0] as! BackgroundAnimationViewController
        backgroundAnimationRootViewController.pageMainViewControllerDelegate = self
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileIndexNavigationController = profileStoryboard.instantiateViewControllerWithIdentifier("ProfileNavigationController") as! UINavigationController
        self.add([backgroundAnimationNavigationController, profileIndexNavigationController])
        self.showPageControl = false
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TODO: terrance showed me how to lock a page, now I just need to use the delegate to have function that says to do something.
//     override func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
//        return lockPaging ? nil : super.pageViewController(pageViewController, viewControllerBeforeViewController: viewController)
//    }
//    
//     override func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
//        return lockPaging ? nil : super.pageViewController(pageViewController, viewControllerAfterViewController: viewController)
//    }
}

protocol PageMainViewControllerDelegate {
    func moveToPageIndex(index: Int)
}

extension PageMainViewController: PageMainViewControllerDelegate {
    func moveToPageIndex(index: Int) {
        self.goTo(index)
    }
}
