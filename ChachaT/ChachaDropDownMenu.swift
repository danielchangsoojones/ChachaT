//
//  ChachaDropDownMenu.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import SnapKit

protocol ChachaDropDownMenuDelegate {
    func moveChoicesTagListViewDown(_ moveDown: Bool, animationDuration: TimeInterval, springWithDamping: CGFloat, initialSpringVelocity: CGFloat, downDistance: CGFloat)
}

//I used code from the BTNavigationDropdownMenu framework to help me figure this out
class ChachaDropDownMenu: UIView {
    fileprivate struct DropDownConstants {
        static let dropDownBackgroundColor: UIColor = UIColor.white
    }
    
    let springWithDamping : CGFloat = 0.7
    let initialSpringVelocity : CGFloat = 0.5
    
    var delegate: ChachaDropDownMenuDelegate?
    
    // The animation duration of showing/hiding menu. Default is 0.3
    var animationDuration: TimeInterval! {
        get {
            return self.configuration.animationDuration
        }
        set(value) {
            self.configuration.animationDuration = value
        }
    }
    
    // The color of the mask layer. Default is blackColor()
    var maskBackgroundColor: UIColor! {
        get {
            return self.configuration.maskBackgroundColor
        }
        set(value) {
            self.configuration.maskBackgroundColor = value
        }
    }
    
    // The opacity of the mask layer. Default is 0.3
    var maskBackgroundOpacity: CGFloat! {
        get {
            return self.configuration.maskBackgroundOpacity
        }
        set(value) {
            self.configuration.maskBackgroundOpacity = value
        }
    }
    
    var isShown: Bool!
    
    fileprivate var configuration = DropDownConfiguration()
    fileprivate var backgroundView: UIView!
    fileprivate var menuWrapper: UIView!
    var dropDownView: UIView!
    fileprivate var dropDownOriginY : CGFloat = 0
    var innerView: UIView?
    var arrowImage : UIImageView!
    let screenSizeWidth = UIScreen.main.bounds.width
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(containerView: UIView = UIApplication.shared.keyWindow!, popDownOriginY: CGFloat, delegate: ChachaDropDownMenuDelegate) {
        //need to super init, but do not have the height yet, so just passing a size zero frame
        super.init(frame: CGRect.zero)
        
        self.delegate = delegate
        self.dropDownOriginY = popDownOriginY
        self.isShown = false
        
        //getting the top view controllers bounds
        let window = UIScreen.main
        let menuWrapperBounds = window.bounds
        
        // Set up DropdownMenu
        self.menuWrapper = UIView(frame: CGRect(x: menuWrapperBounds.origin.x, y: 0, width: menuWrapperBounds.width, height: menuWrapperBounds.height))
        self.menuWrapper.clipsToBounds = true
        self.menuWrapper.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ChachaDropDownMenu.hideMenu))
        swipeUpRecognizer.direction = .up
        menuWrapper.addGestureRecognizer(swipeUpRecognizer)
        
        // Init background view (under top view)
        self.backgroundView = UIView(frame: menuWrapperBounds)
        self.backgroundView.backgroundColor = self.configuration.maskBackgroundColor
        self.backgroundView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChachaDropDownMenu.hideMenu));
        self.backgroundView.addGestureRecognizer(backgroundTapRecognizer)
        
        dropDownView = UIView(frame: CGRect(x: 0, y: 0, width: menuWrapper.frame.width, height: 0))
        dropDownView.backgroundColor = DropDownConstants.dropDownBackgroundColor
        self.arrowImage = setArrowImageToView(dropDownView)
        
        // Add background view & table view to container view
        self.menuWrapper.addSubview(self.backgroundView)
        self.menuWrapper.addSubview(dropDownView)
        
        // Add Menu View to container view
        containerView.addSubview(self.menuWrapper)
        
        // By default, hide menu view
        self.menuWrapper.isHidden = true
    }
    
    func hide() {
        if self.isShown == true {
            self.hideMenu()
        }
    }
    
    func show() {
        if self.isShown == false {
            self.showMenu()
        }
    }
    
    func toggle() {
        if(self.isShown == true) {
            self.hideMenu();
        } else {
            self.showMenu();
        }
    }
    
    fileprivate func showMenu() {
        self.menuWrapper.frame.origin.y = dropDownOriginY
        
        self.isShown = true
        resignFirstResponder() //don't want a keyboard up when the menu gets shown.
        
        // Visible menu view
        self.menuWrapper.isHidden = false
        
        // Change background alpha
        self.backgroundView.alpha = 0
        
        // Animation
        self.dropDownView.frame.origin.y = 0
        
        self.menuWrapper.superview?.bringSubview(toFront: self.menuWrapper)
        self.arrowImage.bringSubview(toFront: self.dropDownView)
        
        delegate?.moveChoicesTagListViewDown(true, animationDuration: configuration.animationDuration * 1.5, springWithDamping:  springWithDamping, initialSpringVelocity: initialSpringVelocity, downDistance: getDropDownViewHeight())
        
        UIView.animate(
            withDuration: self.configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: springWithDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: [],
            animations: {
                self.dropDownView.frame = CGRect(x: self.dropDownView.frame.origin.x, y: self.dropDownView.frame.origin.y, width: self.screenSizeWidth, height: self.getDropDownViewHeight())
                self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
            }, completion: nil
        )
    }
    
    @objc fileprivate func hideMenu() {
        self.isShown = false
        
        // Change background alpha
        self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
        innerView?.removeFromSuperview()
        
        delegate?.moveChoicesTagListViewDown(false, animationDuration: configuration.animationDuration * 1.5, springWithDamping:  springWithDamping, initialSpringVelocity: initialSpringVelocity, downDistance: getDropDownViewHeight())
        
        UIView.animate(
            withDuration: self.configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: springWithDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: [],
            animations: {
                self.dropDownView.frame = CGRect(x: self.dropDownView.frame.origin.x, y: self.dropDownView.frame.origin.y, width: self.screenSizeWidth, height: 0)
            }, completion: nil
        )
        
        // Animation
        UIView.animate(
            withDuration: self.configuration.animationDuration,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                self.backgroundView.alpha = 0
            }, completion: { _ in
                self.menuWrapper.isHidden = true
        })
    }
    
    let arrowImageInset: CGFloat = 20.0
    let arrowImageBottomInsetDivision : CGFloat = 4 //how much I am dividing the arrowImageInset, so it is close to the bottom of the dropdown
    
    func addInnerView(_ sideOffset: CGFloat = 0) {
        dropDownView.addSubview(innerView!)
        //the view will grow to whatever size is necessary to fit its innerView
        innerView!.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(sideOffset)
            make.trailing.equalToSuperview().inset(sideOffset)
            make.top.equalToSuperview()
            make.bottom.equalTo(arrowImage.snp.top).offset(-arrowImageInset) //not sure why inset() does not work, but it doesn't
        }
    }
    
    func setArrowImageToView(_ superView: UIView) -> UIImageView {
        let arrowImage = UIImageView(image: UIImage(named: ImageNames.dropDownUpArrow))
        arrowImage.contentMode = .scaleAspectFit
        let tap = UITapGestureRecognizer(target: self, action: #selector(arrowImagePressed(_:)))
        arrowImage.addGestureRecognizer(tap)
        arrowImage.isUserInteractionEnabled = true
        superView.addSubview(arrowImage)
        arrowImage.snp.makeConstraints { (make) in
            //using low priority because the compiler needs to know which constraints to break when the dropDownHeight is 0
            make.bottom.equalTo(superView).inset(arrowImageInset / arrowImageBottomInsetDivision).priority(250)
            make.height.equalTo(10).priority(250)
            make.width.equalTo(20).priority(250)
            make.centerX.equalTo(superView)
        }
        return arrowImage
    }
    
    func arrowImagePressed(_ sender: UIImageView!) {
        hide()
    }
    
    func getDropDownViewHeight() -> CGFloat {
        let arrowImageHeight = arrowImage.intrinsicContentSize.height
        let arrowImageHeightAndInsets = arrowImageHeight + arrowImageInset + (arrowImageInset / arrowImageBottomInsetDivision)
        return innerView!.intrinsicContentSize.height + arrowImageHeightAndInsets
    }
    
    class DropDownConfiguration {
        var animationDuration: TimeInterval!
        var maskBackgroundColor: UIColor!
        var maskBackgroundOpacity: CGFloat!
        
        init() {
            self.defaultValue()
        }
        
        func defaultValue() {
            self.animationDuration = 0.5
            self.maskBackgroundColor = UIColor.black
            self.maskBackgroundOpacity = 0.6
        }
    }
}
