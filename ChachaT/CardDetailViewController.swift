//
//  SecondVC.swift
//  MagicMove
//
//  Created by Patrick Reynolds on 1/24/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var theFirstBulletText: UILabel!
    @IBOutlet weak var theBottomBlurredView: UIView!
    @IBOutlet weak var theQuestionButtonOne: UIButton!
    @IBOutlet weak var theQuestionButtonTwo: UIButton!
    @IBOutlet weak var theCustomQuestionButton: UIButton!
    @IBOutlet weak var theProfileImageButtonOverlay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBottomBlur()
        setupTapHandler()
    }
    
    func setBottomBlur() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - 100, width:  UIScreen.mainScreen().bounds.width, height: 100)
        let transparent = UIColor(white: 1, alpha: 0).CGColor
        let opaque = UIColor.rgba(red: 1, green: 195, blue: 167, alpha: 0.5).CGColor
        gradientLayer.colors = [transparent, opaque]
        gradientLayer.locations = [0.0, 0.8]
        
        self.view.layer.addSublayer(gradientLayer)
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func setupTapHandler() {
        theProfileImageButtonOverlay.tapped { _ in
            self.imageTapped()
        }

    }
}

extension CardDetailViewController: MagicMoveable {
    func imageTapped() {
        let backgroundAnimationVC = UIStoryboard(name: Storyboards.Main.storyboard, bundle: nil).instantiateViewControllerWithIdentifier(String(BackgroundAnimationViewController)) as! BackgroundAnimationViewController
        
        //not animating right now because it was fucking things up.
        presentViewControllerMagically(self, to: backgroundAnimationVC, animated: false, duration: duration, spring: spring)
    }
    
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
