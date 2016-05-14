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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = theBottomBlurredView.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor]
        theBottomBlurredView.layer.insertSublayer(gradient, atIndex: 0)
        
        setupTapHandler()
    }
    
    func setUI() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector(imageTapped()))
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
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

extension CardDetailViewController: MagicMoveable {
    func imageTapped() {
        let backgroundAnimationVC = UIStoryboard(name: Storyboards.Main.storyboard, bundle: nil).instantiateViewControllerWithIdentifier(String(BackgroundAnimationViewController)) as! BackgroundAnimationViewController
        
        presentViewControllerMagically(self, to: backgroundAnimationVC, animated: true, duration: duration, spring: spring)
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
