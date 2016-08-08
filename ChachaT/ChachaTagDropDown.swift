//
//  ChachaTagDropDown.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/28/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import SnapKit

protocol ChachaTagDropDownDelegate {
    func moveChoicesTagListViewDown(moveDown: Bool, animationDuration: NSTimeInterval, springWithDamping: CGFloat, initialSpringVelocity: CGFloat, downDistance: CGFloat?)
}

//I used code from the BTNavigationDropdownMenu framework to help me figure this out
class ChachaTagDropDown: UIView {
    
    let springWithDamping : CGFloat = 0.7
    let initialSpringVelocity : CGFloat = 0.5
    
    var delegate: ChachaTagDropDownDelegate?
    
    // The animation duration of showing/hiding menu. Default is 0.3
    var animationDuration: NSTimeInterval! {
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
    
    private var configuration = DropDownConfiguration()
    private var backgroundView: UIView!
    private var menuWrapper: UIView!
    private var dropDownView: UIView!
    private var dropDownOriginY : CGFloat = 0
    private var tagListView : TagListView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(containerView: UIView = UIApplication.sharedApplication().keyWindow!, popDownOriginY: CGFloat, delegate: ChachaTagDropDownDelegate) {
        //need to super init, but do not have the height yet, so just passing a size zero frame
        super.init(frame: CGRectZero)
        
        self.delegate = delegate
        self.dropDownOriginY = popDownOriginY
        self.isShown = false
        
        //getting the top view controllers bounds
        let window = UIScreen.mainScreen()
        let menuWrapperBounds = window.bounds
        
        // Set up DropdownMenu
        self.menuWrapper = UIView(frame: CGRectMake(menuWrapperBounds.origin.x, 0, menuWrapperBounds.width, menuWrapperBounds.height))
        self.menuWrapper.clipsToBounds = true
        self.menuWrapper.autoresizingMask = [ .FlexibleWidth, .FlexibleHeight ]
        
        // Init background view (under table view)
        self.backgroundView = UIView(frame: menuWrapperBounds)
        self.backgroundView.backgroundColor = self.configuration.maskBackgroundColor
        self.backgroundView.autoresizingMask = [ .FlexibleWidth, .FlexibleHeight ]
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChachaTagDropDown.hideMenu));
        self.backgroundView.addGestureRecognizer(backgroundTapRecognizer)
        
        dropDownView = UIView(frame: CGRectMake(0, 0, menuWrapper.frame.width, 0))
        dropDownView.backgroundColor = UIColor.blueColor()
        self.tagListView = addTagListViewToView(dropDownView)
        
        // Add background view & table view to container view
        self.menuWrapper.addSubview(self.backgroundView)
        self.menuWrapper.addSubview(dropDownView)
        
        // Add Menu View to container view
        containerView.addSubview(self.menuWrapper)
        
        // By default, hide menu view
        self.menuWrapper.hidden = true
//        self.menuWrapper.backgroundColor = UIColor.redColor()
    }
    
    func show(tagTitles: [String]) {
        if self.isShown == false {
            addTags(tagTitles)
            self.showMenu()
        }
    }
    
    func hide() {
        if self.isShown == true {
            self.hideMenu()
        }
    }
    
    func toggle() {
        if(self.isShown == true) {
            self.hideMenu();
        } else {
            self.showMenu();
        }
    }
    
    private func showMenu() {
        self.menuWrapper.frame.origin.y = dropDownOriginY
        
        self.isShown = true
        
        // Visible menu view
        self.menuWrapper.hidden = false
        
        // Change background alpha
        self.backgroundView.alpha = 0
        
        // Animation
        self.dropDownView.frame.origin.y = 0
        let tagListViewHeight = self.tagListView.intrinsicContentSize().height
        
        self.menuWrapper.superview?.bringSubviewToFront(self.menuWrapper)
        
        delegate?.moveChoicesTagListViewDown(true, animationDuration: configuration.animationDuration * 1.5, springWithDamping:  springWithDamping, initialSpringVelocity: initialSpringVelocity, downDistance: tagListViewHeight)
        
        UIView.animateWithDuration(
            self.configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: springWithDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: [],
            animations: {
                let screenSizeWidth = UIScreen.mainScreen().bounds.width
                self.dropDownView.frame = CGRectMake(self.dropDownView.frame.origin.x, self.dropDownView.frame.origin.y, screenSizeWidth, tagListViewHeight)
                self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
            }, completion: nil
        )
    }
    
    @objc private func hideMenu() {
        self.isShown = false
        
        // Change background alpha
        self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
        tagListView.removeAllTags() //menu is disappearing, so I want to get rid of all tags
        
        delegate?.moveChoicesTagListViewDown(false, animationDuration: configuration.animationDuration * 1.5, springWithDamping:  springWithDamping, initialSpringVelocity: initialSpringVelocity, downDistance: nil)
        
        UIView.animateWithDuration(
            self.configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: springWithDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: [],
            animations: {
                self.dropDownView.frame = CGRectMake(self.dropDownView.frame.origin.x, self.dropDownView.frame.origin.y, UIScreen.mainScreen().bounds.width, 0)
            }, completion: nil
        )
        
        // Animation
        UIView.animateWithDuration(
            self.configuration.animationDuration,
            delay: 0,
            options: UIViewAnimationOptions.TransitionNone,
            animations: {
                self.backgroundView.alpha = 0
            }, completion: { _ in
                self.menuWrapper.hidden = true
        })
    }
    
    func addTags(titleArray: [String]) {
        for title in titleArray {
            tagListView.addTag(title)
        }
    }
    
    func addTagListViewToView(view: UIView) -> TagListView {
        let tagListView = ChachaChoicesTagListView(frame: CGRectZero)
        view.addSubview(tagListView)
        tagListView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        return tagListView
    }
    
    class DropDownConfiguration {
        var animationDuration: NSTimeInterval!
        var maskBackgroundColor: UIColor!
        var maskBackgroundOpacity: CGFloat!
        
        init() {
            self.defaultValue()
        }
        
        func defaultValue() {
            self.animationDuration = 0.5
            self.maskBackgroundColor = UIColor.blackColor()
            self.maskBackgroundOpacity = 0.3
        }
    }
}
