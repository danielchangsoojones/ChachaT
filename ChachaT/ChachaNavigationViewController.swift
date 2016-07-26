//
//  ChachaNavigationViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/25/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class ChachaNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //hacky way of getting the navigation bar to look like Tinder's and have no background bar, just the buttons.
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()

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
