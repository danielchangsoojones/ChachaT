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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let backgroundAnimationViewController = storyboard.instantiateViewControllerWithIdentifier("BackgroundAnimationViewController") as! BackgroundAnimationViewController
        backgroundAnimationViewController.pageMainViewControllerDelegate = self
        let cardDetailViewController = storyboard.instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        cardDetailViewController.questionDetailState = .ProfileViewOnlyMode
        self.add([backgroundAnimationViewController, cardDetailViewController])
        self.showPageControl = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .Plain, target: self, action: #selector(PageMainViewController.logOut))

        // Do any additional setup after loading the view.
    }
    
    func logOut() {
        User.logOut()
        performSegueWithIdentifier(.LogInPageSegue, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
