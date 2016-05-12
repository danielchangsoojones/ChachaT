//
//  SecondVC.swift
//  MagicMove
//
//  Created by Patrick Reynolds on 1/24/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit

class SecondVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var theFirstBulletText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapHandler()
    }
    
    private func setupTapHandler() {
//        blueButton.tapped { _ in
//            self.nextButtonTappedHandler()
//        }
//        
//        backButton.tapped { _ in
//            self.backButtonTappedHander()
//        }
    }
    
    private func nextButtonTappedHandler() {
//        let thirdVC = UIStoryboard(name: Storyboards.Main.storyboard, bundle: nil).instantiateViewControllerWithIdentifier(String(ThirdVC)) as! ThirdVC
//        
//        presentViewControllerMagically(self, to: thirdVC, animated: true)
    }
    
//    private func backButtonTappedHander() {
//        let firstVC = UIStoryboard(name: Storyboards.Main.storyboard, bundle: nil).instantiateViewControllerWithIdentifier(String(FirstVC)) as! FirstVC
//        
//        presentViewControllerCustomTrasition(firstVC, transition: FadeTransition(), animated: true)
//    }
}

extension SecondVC: MagicMoveable {
    var isMagic: Bool {
        return true
    }
    
    var duration: NSTimeInterval {
        return 1.0
    }
    
    var spring: CGFloat {
        return 1.0
    }
    
    var magicViews: [UIView] {
        return [imageView]
    }
}
