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
        //for some reason, to make the navigation bar invisible except for buttons, I have to add empty image, so then it overrides the default navigation translucency, ect.
        //these next two code lines are able to override the default so I get the tinder looking nav bar.
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barStyle = .BlackTranslucent
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
