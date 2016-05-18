//
//  UserDetailPopUpViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class UserDetailPopUpViewController: UIViewController {
    
    var keyboardHeight : CGFloat = 216

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About You"
        
        contentSizeInPopup = CGSizeMake(self.view.bounds.width - 75, self.view.bounds.height - keyboardHeight - 100)
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
