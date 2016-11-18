//
//  SettingsViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/17/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Former

class SettingsViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addLastSection()
    }
    
    func addLastSection() {
        let header = LabelViewFormer<FormLabelHeaderView>() { view in
            view.titleLabel.text = "Log Out"
        }
        
        let logoutRow = LabelRowFormer<FormLabelCell>().configure { (row: LabelRowFormer<FormLabelCell>) in
            row.text = "Log Out"
        }.onSelected { (_) in
            self.logOut()
        }
        
        let section = SectionFormer(rowFormer: logoutRow).set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }
    
    fileprivate func logOut() {
        User.logOut()
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let logInVC = storyboard.instantiateViewController(withIdentifier: "SignUpLogInViewController") as! SignUpLogInViewController
        presentVC(logInVC)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
