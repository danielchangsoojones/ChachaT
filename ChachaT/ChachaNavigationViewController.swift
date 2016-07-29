//
//  ChachaNavigationViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/25/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import SnapKit

class ChachaNavigationViewController: UINavigationController {
    
    var navigationBarLogo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //hacky way of getting the navigation bar to look like Tinder's and have no background bar, just the buttons.
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationBarLogo = setNavigationLogo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setNavigationLogo() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .ScaleAspectFit
        let logo = UIImage(named: "Chacha-Teal-Logo")
        imageView.image = logo
        imageView.alpha = 0.5
        self.navigationBar.addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
            make.center.equalTo(self.navigationBar)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        return imageView
    }

}
