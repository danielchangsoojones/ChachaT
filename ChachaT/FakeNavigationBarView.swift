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

//Daniel Jones created a fakeNavigationBarView because originally, we wanted the bar to expand when the menu button was clicked. But, later, it was better to just use a side menu. So, technically we don't need to use a fake navigation bar anymore, but I think it allows for more custumization if we decided to change things. 
class FakeNavigationBarView : UIView {
    var leftMenuButton: UIButton!
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
        createRightBarButton()
        createLeftBarButton()
        createLogo()
    }
    
    func createLogo() {
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo"))
        logoImageView.contentMode = .scaleAspectFit
        self.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(ImportantDimensions.StatusBarHeight / 2)
            make.height.equalTo(40)
            make.width.equalTo(40)
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
    
    func createLeftBarButton() {
        leftMenuButton = UIButton(frame: CGRect(x: 0, y: 0, width: ImportantDimensions.BarButtonItemSize.width, height: ImportantDimensions.BarButtonItemSize.height))
        leftMenuButton.addTarget(self, action: #selector(FakeNavigationBarView.leftBarButtonPressed(_:)), for: .touchUpInside)
        self.addSubview(leftMenuButton)
        leftMenuButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(ImportantDimensions.BarButtonInset)
            make.centerY.equalTo(self).offset(ImportantDimensions.StatusBarHeight / 2)
        }
        leftMenuButton.setImage(#imageLiteral(resourceName: "Notification Tab Icon"), for: UIControlState())
    }
    
    func leftBarButtonPressed(_ sender: UIButton!) {
        delegate?.leftBarButtonPressed()
    }
    
    func incrementNotifications(_ amount: Int) {
        if hub == nil {
            //the hub does not exist yet
            hub = RKNotificationHub(view: leftMenuButton)
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
}

protocol FakeNavigationBarDelegate {
    func rightBarButtonPressed(_ sender: UIButton!)
    func leftBarButtonPressed()
}

extension BackgroundAnimationViewController: FakeNavigationBarDelegate {
    func rightBarButtonPressed(_ sender: UIButton!) {
        performSegue(withIdentifier: SegueIdentifier.CustomBackgroundAnimationToSearchSegue.rawValue, sender: self)
    }
    
    func leftBarButtonPressed() {
        let frostedSideBar = FrostedSidebar(itemImages: [#imageLiteral(resourceName: "WhiteMessageIcon"), #imageLiteral(resourceName: "MyTagIcon"), #imageLiteral(resourceName: "ProfileIcon")], colors: [CustomColors.JellyTeal, CustomColors.JellyTeal, CustomColors.JellyTeal], selectionStyle: .all)
        frostedSideBar.selectionStyle = .all
        frostedSideBar.delegate = self
        frostedSideBar.showInViewController(self, animated: true)
    }
}
