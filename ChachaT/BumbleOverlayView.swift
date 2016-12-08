//
//  BumbleOverlayView.swift
//  BumbleTesting
//
//  Created by Daniel Jones on 12/5/16.
//  Copyright © 2016 Daniel Jones. All rights reserved.
//

import UIKit
import SnapKit

class BumbleOverlayView: UIView {
    var theBumbleDetailView: BumbleDetailView!
    var pageControl: CustomPageControl!
    let minAlpha: CGFloat = 0
    
    init(frame: CGRect, numberOfPhotos: Int) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(minAlpha)
        cardDetailSetup()
        addCardDetailTapGesture()
        addBackgroundTapGesture()
        addPan()
        pageControlSetup(numberOfPhotos: numberOfPhotos)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func cardDetailSetup() {
        theBumbleDetailView = BumbleDetailView(frameWidth: self.frame.width, frameMinY: self.bounds.maxY - 100, height: 100)
        theBumbleDetailView.backgroundColor = UIColor.red
        self.addSubview(theBumbleDetailView)
        theBumbleDetailView.setMaxFrame()
    }
    
    //allows us to check where the hit occurred and then decide if we want userInteraction for that point, or let it pass on to other views behind it. Basically like isUserInteractionEnabled, but we can choose individual points to be enabled.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if theBumbleDetailView.frame.contains(point) || theBumbleDetailView.isOpen {
            return true
        }
        //pass the tap onto other views
        return false
    }
}

//page controller extension
extension BumbleOverlayView {
    fileprivate func pageControlSetup(numberOfPhotos: Int) {
        pageControl = CustomPageControl(numberOfPages: numberOfPhotos + 1) //+1 for the cardDetailCircle
        self.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
        }
    }
    
    func movePageControl(to page: CGFloat, goToFinalDot: Bool = false) {
        if goToFinalDot {
            pageControl.progress = CGFloat(pageControl.pageCount - 1)
        } else {
            pageControl.progress = page
        }
    }
}

//handle tap
extension BumbleOverlayView {
    fileprivate func addBackgroundTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleDetailTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    fileprivate func addCardDetailTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleDetailTap(_:)))
        theBumbleDetailView.addGestureRecognizer(tap)
    }
    
    func handleDetailTap(_ sender: UIGestureRecognizer) {
        if theBumbleDetailView.isOpen {
            animateToOriginalFrame()
        } else {
            animateToMaxFrame()
        }
    }
}

//handlind pan
extension BumbleOverlayView {
    func addPan() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.isPanning(pan:)))
        self.addGestureRecognizer(pan)
    }
    
    func isPanning(pan: UIPanGestureRecognizer) {
        let pointOfTouch = pan.location(in: self)
        let velocity = pan.velocity(in: self)
        
        var direction: UISwipeGestureRecognizerDirection?
        if velocity.y < 0 {
            direction = .up
        } else if velocity.y > 0 {
            direction = .down
        }
        
        self.pan(touchPoint: pointOfTouch, direction: direction, state: pan.state)
    }
    
    func pan(touchPoint: CGPoint, direction: UISwipeGestureRecognizerDirection?, state: UIGestureRecognizerState) {
        if state == .ended {
            if let direction = direction {
                finishSwipe(direction: direction)
            } else {
                finishNonVelocityDrag()
            }
        } else {
            animateDetailView(pointOfTouch: touchPoint)
        }
    }
    
    fileprivate func finishSwipe(direction: UISwipeGestureRecognizerDirection) {
        if direction == .up {
            animateToMaxFrame()
        } else if direction == .down {
            animateToOriginalFrame()
        }
    }
    
    fileprivate func finishNonVelocityDrag() {
        if theBumbleDetailView.frame.minY <= theBumbleDetailView.finishSwipeThresholdY {
            animateToMaxFrame()
        } else {
            animateToOriginalFrame()
        }
    }
    
    fileprivate func animateToMaxFrame() {
        animateDetailView(pointOfTouch: theBumbleDetailView.maxFrame.origin)
    }
    
    fileprivate func animateToOriginalFrame() {
        animateDetailView(pointOfTouch: theBumbleDetailView.originalFrame.origin)
    }
    
    fileprivate func animateDetailView(pointOfTouch: CGPoint) {
        UIView.animate(withDuration: 0.3, animations: {
            //open being when the cardDetail is showing its inner contents
            let openY = self.theBumbleDetailView.maxFrame.minY
            let closedY = self.theBumbleDetailView.originalFrame.minY
            let openInset = self.theBumbleDetailView.originalFrameInset
            let closedInset = self.theBumbleDetailView.maxFrameInset
            
            var currentTouchY = pointOfTouch.y
            if currentTouchY < openY {
                currentTouchY = openY
            } else if currentTouchY > closedY {
                currentTouchY = closedY
            }
            
            let percentOpened = (closedY - currentTouchY) / (closedY - openY)
            let inset = (1 - percentOpened) * (openInset - closedInset) + closedInset
            self.theBumbleDetailView.frame = CGRect(x: inset, y: currentTouchY, width: self.frame.maxX - inset * 2, height: self.frame.maxY - currentTouchY - inset)
            self.updateAlpha(percentOpened: percentOpened)
        }, completion: { (success: Bool) in
            self.updatePageControl()
        })
    }
    
    fileprivate func updateAlpha(percentOpened: CGFloat) {
        let maxAlpha: CGFloat = 0.8
        let alphaDifference = maxAlpha - minAlpha
        let targetAlpha = (alphaDifference * percentOpened) + minAlpha
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(targetAlpha)
    }
    
    fileprivate func updatePageControl() {
        if theBumbleDetailView.frame == theBumbleDetailView.maxFrame {
            self.movePageControl(to: -1, goToFinalDot: true)
        } else if theBumbleDetailView.frame == theBumbleDetailView.originalFrame {
            self.movePageControl(to: pageControl.previousProgress)
        }
    }
}
