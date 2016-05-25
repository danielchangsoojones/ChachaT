//
//  PageMainViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/24/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Pages

class PageMainViewController: PagesController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let backgroundAnimationViewController = storyboard.instantiateViewControllerWithIdentifier("BackgroundAnimationViewController") as! BackgroundAnimationViewController
        let cardDetailViewController = storyboard.instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        self.add([backgroundAnimationViewController, cardDetailViewController])
        
        self.showPageControl = false

        // Do any additional setup after loading the view.
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
