//
//  BottomPicturePopUpViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class BottomPicturePopUpViewController: UIViewController {
    
    @IBOutlet weak var thePhotoLibraryButton: UIButton!
    @IBOutlet weak var theCameraButton: UIButton!
    
    @IBAction func thePhotoLibraryButtonPressed(sender: AnyObject) {
    }

    @IBAction func theCameraButtonPressed(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let extraHeight : CGFloat = 45
        contentSizeInPopup = CGSizeMake(self.view.bounds.width, thePhotoLibraryButton.frame.height + theCameraButton.frame.height + extraHeight)
        
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
