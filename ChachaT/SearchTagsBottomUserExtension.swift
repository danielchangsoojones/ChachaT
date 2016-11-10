//
//  SearchTagsBottomUserExtension.swift
//  ChachaT
//
//  Created by Daniel Jones on 11/9/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation

extension SearchTagsViewController {
    func hideBottomUserArea() {
        toggleBottomUserArea(show: false)
        theTagScrollView.contentInset.bottom = 0
    }
    
    func toggleBottomUserArea(show: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            //move the frame to the correct y position
            if show {
                self.theBottomUserArea?.frame.y -= self.theBottomUserArea?.frame.height ?? 0
            } else {
                //hiding the menu, push it off the screen
                self.theBottomUserArea?.frame.y = self.view.frame.maxY
            }
        })
    }
    
    func showBottomUserArea(swipes: [Swipe]) {
        theBottomUserArea = BottomUserScrollView(swipes: swipes, frame: CGRect(x: 0, y: self.view.frame.maxY, w: self.view.frame.width, h: self.view.frame.height / 3), delegate: self)
        self.view.addSubview(theBottomUserArea!)
        
        toggleBottomUserArea(show: true)
        
        theTagScrollView.contentInset.bottom = theBottomUserArea!.frame.height
    }
}

extension SearchTagsViewController: EmptyStateDelegate {
    func emptyStateButtonPressed() {
        //Do something when they click the empty search button
        resetSearch()
    }
    
    func resetSearch() {
        for tagView in tagChosenView.tagViews {
            removeTag(tagView: tagView, tagListView: tagChosenView)
        }
        hideBottomUserArea()
    }
    
    func showEmptyState() {
        let emptyStateView = SearchingEmptyStateView(delegate: self)
        theBottomUserArea?.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func hideEmptyState() {
        for subview in theBottomUserArea?.subviews ?? [] {
            if subview is SearchingEmptyStateView {
                subview.removeFromSuperview()
            }
        }
    }
}
