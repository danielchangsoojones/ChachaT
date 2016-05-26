//
//  UserDetailPopUpViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse

class UserDetailPopUpViewController: PopUpSuperViewController {
    
    var keyboardHeight : CGFloat = 216
    @IBOutlet weak var theDescriptionTextView: UITextView!
    @IBOutlet weak var theSaveButton: UIButton!
    
    var factNumber: Fact?
    var factDescriptionText: String?
    
    var delegate: PopUpViewControllerDelegate?
    
    @IBAction func save(sender: AnyObject) {
        theSaveButton.enabled = false
        let currentUser = User.currentUser()
        currentUser?.factOne = theDescriptionTextView.text
        theActivitySpinner.hidden = false
        theActivitySpinner.startAnimating()
        currentUser?.saveInBackgroundWithBlock({ (success, error) in
            if success {
                self.delegate?.passFactDescription(self.theDescriptionTextView.text, fact: self.factNumber!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        })
    }
    
    @IBAction func clearText(sender: AnyObject) {
        theDescriptionTextView.text = ""
        theDescriptionTextView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About You"
        contentSizeInPopup = CGSizeMake(self.view.bounds.width - 75, self.view.bounds.height - keyboardHeight - 100)
        theDescriptionTextView.text = factDescriptionText
        
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
