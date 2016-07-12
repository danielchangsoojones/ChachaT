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
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .Plain, target: self, action: #selector(PageMainViewController.logOut))
//        setChachaNavigationLogo()
        
        // Do any additional setup after loading the view.
    }
    
    func setChachaNavigationLogo() {
        let logo = UIImage(named: "ChaCha-Logo-White")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.image = logo
        imageView.contentMode = .ScaleAspectFit
        let titleView = UIView(frame: CGRectMake(0,0, 150,40))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        self.navigationItem.titleView = titleView
    }
    
    func logOut() {
        User.logOut()
        performSegueWithIdentifier(.LogInPageSegue, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

protocol PageMainViewControllerDelegate {
    func moveToPageIndex(index: Int)
}

extension PageMainViewController: PageMainViewControllerDelegate {
    func moveToPageIndex(index: Int) {
        self.goTo(index)
    }
}

extension PageMainViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        // THESE CASES WILL ALL MATCH THE IDENTIFIERS YOU CREATED IN THE STORYBOARD
        case LogInPageSegue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}
