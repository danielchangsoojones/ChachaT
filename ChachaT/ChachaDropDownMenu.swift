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
    func moveChoicesTagListViewDown(moveDown: Bool, animationDuration: NSTimeInterval, springWithDamping: CGFloat, initialSpringVelocity: CGFloat, downDistance: CGFloat?)
}

//I used code from the BTNavigationDropdownMenu framework to help me figure this out
class ChachaDropDownMenu: UIView {
    private struct DropDownConstants {
        static let dropDownBackgroundColor: UIColor = UIColor.whiteColor()
    }
    
    let springWithDamping : CGFloat = 0.7
    let initialSpringVelocity : CGFloat = 0.5
    
    var delegate: ChachaDropDownMenuDelegate?
    
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
    var tagListView : TagListView?
    var singleSliderView: SingleSliderView?
    var rangeSliderView: DoubleRangeSliderView?
    var arrowImage : UIImageView!
    let screenSizeWidth = UIScreen.mainScreen().bounds.width
    var dropDownMenuType: TagAttributes = .SpecialtyTagMenu //just giving it a default
    var dropDownMenuCategoryType: SpecialtyCategoryTitles = .Ethnicity //had to give it an arbitrary defualt value
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(containerView: UIView = UIApplication.sharedApplication().keyWindow!, popDownOriginY: CGFloat, delegate: ChachaDropDownMenuDelegate) {
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
        
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ChachaDropDownMenu.hideMenu))
        swipeUpRecognizer.direction = .Up
        menuWrapper.addGestureRecognizer(swipeUpRecognizer)
        
        // Init background view (under top view)
        self.backgroundView = UIView(frame: menuWrapperBounds)
        self.backgroundView.backgroundColor = self.configuration.maskBackgroundColor
        self.backgroundView.autoresizingMask = [ .FlexibleWidth, .FlexibleHeight ]
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChachaDropDownMenu.hideMenu));
        self.backgroundView.addGestureRecognizer(backgroundTapRecognizer)
        
        dropDownView = UIView(frame: CGRectMake(0, 0, menuWrapper.frame.width, 0))
        dropDownView.backgroundColor = DropDownConstants.dropDownBackgroundColor
        self.arrowImage = setArrowImageToView(dropDownView)
        
        // Add background view & table view to container view
        self.menuWrapper.addSubview(self.backgroundView)
        self.menuWrapper.addSubview(dropDownView)
        
        // Add Menu View to container view
        containerView.addSubview(self.menuWrapper)
        
        // By default, hide menu view
        self.menuWrapper.hidden = true
    }
    
    func showTagListView(tagTitles: [String], specialtyCategoryTitle: SpecialtyCategoryTitles) {
        if self.isShown == false {
            dropDownMenuType = .SpecialtyTagMenu //even though defualted to this, I need to make sure it changes when it was a different type, and then goes back to .SpecialtyTagMenu
            dropDownMenuCategoryType = specialtyCategoryTitle
            self.tagListView = addTagListViewToView(dropDownView)
            addTags(tagTitles)
            self.showMenu()
        }
    }
    
    func showSingleSliderView() {
        if self.isShown == false {
            dropDownMenuType = .SpecialtySingleSlider
            self.singleSliderView = addSingleSliderViewToView(dropDownView)
            self.showMenu()
        }
    }
    
    func showRangeSliderView(delegate: DoubleRangeSliderViewDelegate, dropDownMenuCategoryType: SpecialtyCategoryTitles) {
        if self.isShown == false {
            self.dropDownMenuCategoryType = dropDownMenuCategoryType
            dropDownMenuType = dropDownMenuCategoryType.associatedTagAttribute!
            self.rangeSliderView = addDoubleRangeSliderToView(dropDownView, delegate: delegate)
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
        resignFirstResponder() //don't want a keyboard up when the menu gets shown.
        
        // Visible menu view
        self.menuWrapper.hidden = false
        
        // Change background alpha
        self.backgroundView.alpha = 0
        
        // Animation
        self.dropDownView.frame.origin.y = 0
        
        self.menuWrapper.superview?.bringSubviewToFront(self.menuWrapper)
        self.arrowImage.bringSubviewToFront(self.dropDownView)
        
        delegate?.moveChoicesTagListViewDown(true, animationDuration: configuration.animationDuration * 1.5, springWithDamping:  springWithDamping, initialSpringVelocity: initialSpringVelocity, downDistance: getDropDownViewHeight())
        
        UIView.animateWithDuration(
            self.configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: springWithDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: [],
            animations: {
                self.dropDownView.frame = CGRectMake(self.dropDownView.frame.origin.x, self.dropDownView.frame.origin.y, self.screenSizeWidth, self.getDropDownViewHeight())
                self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
            }, completion: nil
        )
    }
    
    @objc private func hideMenu() {
        self.isShown = false
        
        // Change background alpha
        self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
        tagListView?.removeFromSuperview()
        singleSliderView?.removeFromSuperview()
        rangeSliderView?.removeFromSuperview()
        
        delegate?.moveChoicesTagListViewDown(false, animationDuration: configuration.animationDuration * 1.5, springWithDamping:  springWithDamping, initialSpringVelocity: initialSpringVelocity, downDistance: nil)
        
        UIView.animateWithDuration(
            self.configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: springWithDamping,
            initialSpringVelocity: initialSpringVelocity,
            options: [],
            animations: {
                self.dropDownView.frame = CGRectMake(self.dropDownView.frame.origin.x, self.dropDownView.frame.origin.y, self.screenSizeWidth, 0)
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
            tagListView?.addTag(title)
        }
    }
    
    let arrowImageInset: CGFloat = 20.0
    let arrowImageBottomInsetDivision : CGFloat = 4 //how much I am dividing the arrowImageInset, so it is close to the bottom of the dropdown
    
    func addTagListViewToView(view: UIView) -> TagListView {
        let tagListView = ChachaChoicesTagListView(frame: CGRectMake(0, 0, screenSizeWidth, 0))
        view.addSubview(tagListView)
        tagListView.tag = 3 //need to set this, so I can know which tagView (i.e. tagChosenView = 2, tagChoicesView = 1, dropDownTagView (this) = 3).
        tagListView.snp_makeConstraints { (make) in
            make.trailing.leading.equalTo(view)
            make.top.equalTo(view)
            make.height.equalTo(32).priorityLow()
            //using low priority because the compiler needs to know which constraints to break when the dropDownHeight is 0
            make.bottom.equalTo(arrowImage.snp_top).offset(-arrowImageInset).priorityLow() //not sure why inset(5) does not work, but it doesn't
        }
        return tagListView
    }
    
    func addSingleSliderViewToView(view: UIView) -> SingleSliderView {
        let theSliderView = SingleSliderView()
        let sliderIntitalValue = theSliderView.theSlider.maximumValue / 2
        theSliderView.theSlider.setValue(sliderIntitalValue, animated: false) //I have to set the initial value here, can't set in actual class for some reason
        theSliderView.theSliderLabel.text =  "\(Int(sliderIntitalValue)) mi."
        view.addSubview(theSliderView)
        theSliderView.snp_makeConstraints { (make) in
            make.trailing.equalTo(view).inset(10)
            make.leading.equalTo(view).offset(10)
            //using low priority because the compiler needs to know which constraints to break when the dropDownHeight is 0
            make.bottom.equalTo(arrowImage.snp_top).offset(-arrowImageInset).priorityLow() //not sure why inset(5) does not work, but it doesn't
        }
        return theSliderView
    }
    
    func addDoubleRangeSliderToView(view: UIView, delegate: DoubleRangeSliderViewDelegate) -> DoubleRangeSliderView {
        let theSliderView = DoubleRangeSliderView(delegate: delegate, sliderCategoryType: dropDownMenuCategoryType)
        theSliderView.theDoubleRangeLabel.text =  "\(Int(theSliderView.theDoubleRangeSlider.minValue)) - \(Int(theSliderView.theDoubleRangeSlider.maxValue))"
        view.addSubview(theSliderView)
        theSliderView.snp_makeConstraints { (make) in
            make.trailing.equalTo(view).inset(10)
            make.leading.equalTo(view).offset(10)
            //using low priority because the compiler needs to know which constraints to break when the dropDownHeight is 0
            make.bottom.equalTo(arrowImage.snp_top).offset(-arrowImageInset).priorityLow() //not sure why inset(5) does not work, but it doesn't
        }
        return theSliderView
    }
    
    func setArrowImageToView(superView: UIView) -> UIImageView {
        let arrowImage = UIImageView(image: UIImage(named: ImageNames.dropDownUpArrow))
        arrowImage.contentMode = .ScaleAspectFit
        let tap = UITapGestureRecognizer(target: self, action: #selector(arrowImagePressed(_:)))
        arrowImage.addGestureRecognizer(tap)
        arrowImage.userInteractionEnabled = true
        superView.addSubview(arrowImage)
        arrowImage.snp_makeConstraints { (make) in
            //using low priority because the compiler needs to know which constraints to break when the dropDownHeight is 0
            make.bottom.equalTo(superView).inset(arrowImageInset / arrowImageBottomInsetDivision).priorityLow()
            make.height.equalTo(10).priorityLow()
            make.width.equalTo(20).priorityLow()
            make.centerX.equalTo(superView)
        }
        return arrowImage
    }
    
    func arrowImagePressed(sender: UIImageView!) {
        hide()
    }
    
    func getDropDownViewHeight() -> CGFloat {
        let arrowImageHeight = arrowImage.intrinsicContentSize().height
        let arrowImageHeightAndInsets = arrowImageHeight + arrowImageInset + (arrowImageInset / arrowImageBottomInsetDivision)
        switch dropDownMenuType {
        case .SpecialtyTagMenu:
            let tagListViewHeight = tagListView!.intrinsicContentSize().height
            return tagListViewHeight + arrowImageHeightAndInsets
        case .SpecialtySingleSlider:
            return singleSliderView!.frame.height + arrowImageHeightAndInsets
        case .SpecialtyRangeSlider:
            return rangeSliderView!.frame.height + arrowImageHeightAndInsets
        }
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
            self.maskBackgroundOpacity = 0.6
        }
    }
}
