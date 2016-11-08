//
//  BackgroundAnimationDataStore.swift
//  ChachaT
//
//  Created by Daniel Jones on 9/13/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import SCLAlertView
import CoreLocation
import Parse

class BackgroundAnimationDataStore {
    
    var parseSwipes: [ParseSwipe] = []
    
    var delegate: BackgroundAnimationDataStoreDelegate?
    
    init(delegate: BackgroundAnimationDataStoreDelegate) {
        self.delegate = delegate
    }
    
    func swipe(swipe: Swipe) {
        //Check if the parseSwipe actually exists and then either update or create a new one. 
        //TODO: Just get the first one out of the array that does this, instead of filtering the whole array
        let filteredArray: [ParseSwipe] = parseSwipes.filter { (parseSwipe: ParseSwipe) -> Bool in
            return parseSwipe.matchesUsers(otherUser: swipe.otherUser);
        }
        if let parseSwipe = filteredArray.first {
            self.updateParseSwipe(parseSwipe: parseSwipe, swipe: swipe)
        }
    }
    
    fileprivate func updateParseSwipe(parseSwipe: ParseSwipe, swipe: Swipe) {
        parseSwipe.currentUserHasSwiped = true
        parseSwipe.currentUserApproval = swipe.currentUserApproval
        parseSwipe.saveInBackground()
    }
    
    func getMoreSwipes() {
        loadSwipeArray()
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
    
    func convertParseSwipeToSwipe(parseSwipe: ParseSwipe) -> Swipe {
        let otherUser = parseSwipe.otherUser
        let swipe = Swipe(otherUser: otherUser, otherUserApproval: parseSwipe.otherUserApproval)
        return swipe
    }
}

extension BackgroundAnimationDataStore {
    func saveCurrentUserLocation(location: CLLocation) {
        User.current()!.location = PFGeoPoint(location: location)
        User.current()!.saveInBackground()
        //saving the location to both the user tag and user because when it comes time to query the Tags while searching. Querying is much easier with having all the queriable stuff in the same place.
        saveLocationToUserTag(location: location)
    }
    
    private func saveLocationToUserTag(location: CLLocation) {
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
