//
//  BackgroundAnimationDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/13/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import CoreLocation
import Parse

class BackgroundAnimationDataStore: SuperParseSwipeDataStore {
    
    var parseSwipes: [ParseSwipe] = []
    
    var delegate: BackgroundAnimationDataStoreDelegate?
    
    init(delegate: BackgroundAnimationDataStoreDelegate) {
        self.delegate = delegate
    }
    
    override init(){
        super.init()
    }
    
    func swipe(swipe: Swipe) {
        //Check if the parseSwipe actually exists and then either update or create a new one.
        self.updateParseSwipe(parseSwipe: swipe.parseSwipe, swipe: swipe)
    }
    
    fileprivate func updateParseSwipe(parseSwipe: ParseSwipe, swipe: Swipe) {
        parseSwipe.currentUserHasSwiped = true
        parseSwipe.currentUserApproval = swipe.currentUserApproval
        parseSwipe.saveInBackground()
    }
    
    func getMoreSwipes(lastSwipe: Swipe) {
        let parseSwipe = lastSwipe.parseSwipe
        parseSwipe.currentUserHasSwiped = true
        parseSwipe.currentUserApproval = lastSwipe.currentUserApproval
        parseSwipe.saveInBackground(block: { (_, _) in
            self.loadSwipeArray()
        })
    }
    
}

//load the swipes
extension BackgroundAnimationDataStore {
    func loadSwipeArray() {
        PFCloud.callFunction(inBackground: "getCurrentUserSwipes", withParameters: [:], block: {
            (result: Any?, error: Error?) -> Void in
            if let parseSwipes = result as? [ParseSwipe] {
                self.parseSwipes = parseSwipes
                let swipes = parseSwipes.map({ (parseSwipe: ParseSwipe) -> Swipe in
                    return self.convertParseSwipeToSwipe(parseSwipe: parseSwipe)
                })
                
                if parseSwipes.isEmpty {
                    print("you have gone through the entire users in the database")
                }
                
                self.delegate?.passUnansweredSwipes(swipes: swipes)
            } else if let error = error {
                print(error)
            }
        })
    }
}

extension BackgroundAnimationDataStore {
    func saveCurrentUserLocation(location: CLLocation) {
        User.current()!.location = PFGeoPoint(location: location)
        User.current()!.saveInBackground()
    }
}

protocol BackgroundAnimationDataStoreDelegate {
    func passUnansweredSwipes(swipes: [Swipe])
}

extension BackgroundAnimationViewController: BackgroundAnimationDataStoreDelegate {
    func passUnansweredSwipes(swipes: [Swipe]) {
        if swipes.isEmpty {
            showEmptyState()
        }
        
        self.swipeArray = swipes
        self.kolodaView.dataSource = self
        self.kolodaView.reloadData()
    }
    
    func showEmptyState() {
        let emptyView = MainPageEmptyStateView(delegate: self)
        self.view.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(fakeNavigationBar.snp.bottom)
        }
    }
}
