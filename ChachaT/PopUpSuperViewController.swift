//
//  PopUpSuperViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/25/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class PopUpSuperViewController: UIViewController {
    
    @IBOutlet weak var theActivitySpinner: UIActivityIndicatorView!
    
    var activeTextField = UITextView()
    
    var placeHolderText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
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

