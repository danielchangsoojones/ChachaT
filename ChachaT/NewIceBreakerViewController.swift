//
//  NewIceBreakerViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/11/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit

class NewIceBreakerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func viewSetup() {
        let theView = NewIceBreakerView(frame: self.view.bounds)
        self.view.addSubview(theView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
