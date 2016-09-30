//
//  FakeNavigationBarView.swift
//  ChachaT
//
//  Created by Daniel Jones on 8/25/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import ExpandingMenu
import SnapKit
import RKNotificationHub

//we created a fake navigation bar because we are turning off the normal navigation bar. Then, we use this view as a fake navigation bar that the user can't tell the difference. We need to do this because we need the view to grow to include the left side menu drop down menu. The normal nav bar shows the buttons, but they aren't clickable because they are outside the nav bars bounds. So, we need to make this view's frame grow, so the buttons become clickable.
class FakeNavigationBarView : UIView {
    var expandingMenuButton: ExpandingMenuButton!
    var navigationBarHeight: CGFloat = 44 //being a good coder, and make the actual view controller pass us the nav bar height, in case that apple changes the nav bar height one day
    var hub : RKNotificationHub?
    
    var delegate: FakeNavigationBarDelegate?
    
    init(navigationBarHeight: CGFloat, delegate: FakeNavigationBarDelegate) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        self.navigationBarHeight = navigationBarHeight
        setNavigationBarItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNavigationBarItems() {
        createExpandingMenuButton() //creates the left Menu Button that creates a drop down menu
        createRightBarButton()
//        createLogo()
    }
    
    func createLogo() {
        let logoImageView = UIImageView(image: UIImage(named: ImageNames.ChachaTealLogo))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = UIColor.red
        self.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(ImportantDimensions.StatusBarHeight / 2)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
    }
    
    func createRightBarButton() {
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: ImportantDimensions.BarButtonItemSize.width, height: ImportantDimensions.BarButtonItemSize.height))
        rightButton.addTarget(self, action: #selector(FakeNavigationBarView.rightBarButtonPressed(_:)), for: .touchUpInside)
        self.addSubview(rightButton)
        rightButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(self).inset(ImportantDimensions.BarButtonInset)
            make.centerY.equalTo(self).offset(ImportantDimensions.StatusBarHeight / 2)
        }
        rightButton.setImage(UIImage(named: ImageNames.SearchIcon), for: UIControlState())
    }
    
    func rightBarButtonPressed(_ sender: UIButton!) {
        delegate?.rightBarButtonPressed(sender)
    }
    
    //This button is the Left Bar Button item
    func createExpandingMenuButton() {
        let menuButtonSize: CGSize = CGSize(width: ImportantDimensions.BarButtonItemSize.width, height: ImportantDimensions.BarButtonItemSize.height) //Can't set snapkit constraints on this because it won't let the drop down menu be created once I add constraints to it.
        //we want the button to be at halfway point in the fake navigation bar. So, we have the midpoint of the superview's frame, but if we just used that, then the origin of the button would start at the midY. So, the origin has to be half of the subview higher.
        let origin : CGPoint = CGPoint(x: ImportantDimensions.BarButtonInset, y: ImportantDimensions.StatusBarHeight + (navigationBarHeight / 2) - (menuButtonSize.height / 2))
        expandingMenuButton = ExpandingMenuButton(frame: CGRect(origin: origin, size: menuButtonSize), centerImage: UIImage(named: "Notification Tab Icon")!, centerHighlightedImage: UIImage(named: "Notification Tab Icon")!)
        self.addSubview(expandingMenuButton)
        configureExpandingMenuButton()
    }
    
    fileprivate func configureExpandingMenuButton() {
        
        let item1 = ExpandingMenuItem(size: nil, title: "Profile", image: UIImage(named: "Notification Tab Icon")!, highlightedImage: UIImage(named: "Notification Tab Icon")!, backgroundImage: nil, backgroundHighlightedImage: nil) { () -> Void in
            self.delegate?.segueToEditProfilePage()
        }
        let item2 = ExpandingMenuItem(size: nil, title: "Add Tags", image: UIImage(named: "Notification Tab Icon")!, highlightedImage: UIImage(named: "Notification Tab Icon")!, backgroundImage: nil, backgroundHighlightedImage: nil) { () -> Void in
            self.delegate?.segueToAddingTagsPage()
        }
        let item3 = ExpandingMenuItem(size: nil, title: "Messaging", image: UIImage(named: "Notification Tab Icon")!, highlightedImage: UIImage(named: "Notification Tab Icon")!, backgroundImage: nil, backgroundHighlightedImage: nil) { () -> Void in
            self.delegate?.segueToMatchesPage()
        }
        let item4 = ExpandingMenuItem(size: nil, title: "Log Out", image: UIImage(named: "Notification Tab Icon")!, highlightedImage: UIImage(named: "Notification Tab Icon")!, backgroundImage: nil, backgroundHighlightedImage: nil) { () -> Void in
            self.delegate?.logOut()
        }
        
        expandingMenuButton.expandingDirection = .bottom
        expandingMenuButton.menuTitleDirection = .right
        expandingMenuButton.addMenuItems([item1, item2, item3, item4])
    }
    
    func incrementNotifications(_ amount: Int) {
        if hub == nil {
            //the hub does not exist yet
            hub = RKNotificationHub(view: expandingMenuButton)
            hub?.setCircleColor(CustomColors.JellyTeal, label: UIColor.white)
            hub?.scaleCircleSize(by: 0.75)
            hub?.moveCircleBy(x: 5, y: -5)
        }
        hub?.increment(by: Int32(amount))
        hub?.pop()
    }
    
    func decrementNotifications(_ amount: Int) {
        hub?.decrement(by: Int32(amount))
        hub?.pop()
    }
    
    //Purpose: overriding this method allows us to click the Expanding menu items outside of the view. When this was not overridden, the buttons were showing up, but not capable of being pushed.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if(!self.clipsToBounds && !self.isHidden && self.alpha > 0.0){
            let subviews = self.subviews.reversed()
            for member in subviews {
                let subPoint = member.convert(point, from: self)
                if let result:UIView = member.hitTest(subPoint, with:event) {
                    return result;
                }
            }
        }
        return nil
    }
}

protocol FakeNavigationBarDelegate {
    func rightBarButtonPressed(_ sender: UIButton!)
    func segueToAddingTagsPage()
    func segueToEditProfilePage()
    func segueToMatchesPage()
    func logOut()
}

extension BackgroundAnimationViewController: FakeNavigationBarDelegate {
    func rightBarButtonPressed(_ sender: UIButton!) {
        performSegue(withIdentifier: SegueIdentifier.CustomBackgroundAnimationToSearchSegue.rawValue, sender: self)
    }
    
    func segueToAddingTagsPage() {
        performSegue(withIdentifier: SegueIdentifier.BackgroundAnimationPageToAddingTagsPageSegue.rawValue, sender: nil)
    }
    
    func segueToMatchesPage() {
        performSegueWithIdentifier(.BackgroundAnimationToMatchesSegue, sender: nil)
    }
    
    func segueToEditProfilePage() {
        performSegue(withIdentifier: SegueIdentifier.BackgroundAnimationToProfileIndexSegue.rawValue, sender: nil)
    }
    
    func logOut() {
        User.logOut()
        performSegueWithIdentifier(.OnboardingPageSegue, sender: self)
    }
}
