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
    var alreadyUsedSwipes: [Swipe] = []
    
    var delegate: BackgroundAnimationDataStoreDelegate?
    
    init(delegate: BackgroundAnimationDataStoreDelegate) {
        self.delegate = delegate
    }
    
    func swipe(swipe: Swipe) {
        //TODO: do a check that this swipe actually exists or we need to make a new one.
        var hasFoundParseSwipe = false
        for parseSwipe in parseSwipes where parseSwipe.matchesUsers(otherUser: swipe.otherUser) {
            parseSwipe.currentUserHasSwiped = true
            parseSwipe.currentUserApproval = swipe.currentUserApproval
            parseSwipe.saveInBackground()
            hasFoundParseSwipe = true
        }
        if !hasFoundParseSwipe {
            //the parseSwipe didn't exist because this is a new user, so we want to save a totally new parseSwipe
            let newParseSwipe = ParseSwipe(otherUser: swipe.otherUser, currentUserApproval: swipe.currentUserApproval)
            newParseSwipe.saveInBackground()
        }
    }
    
    func getMoreSwipes() {
        let alreadyUsedUserIDs: [String] = alreadyUsedSwipes.map { (swipe: Swipe) -> String in
            return swipe.otherUser.objectId!
        }
        getNewUserSwipes(alreadyUsedUserIDs: alreadyUsedUserIDs)
    }
    
}

//load the swipes
extension BackgroundAnimationDataStore {
    func loadSwipeArray() {
        
        let innerUserQuery = User.query()!
        innerUserQuery.whereKey("objectId", equalTo: User.current()!.objectId!)
        
        
        //Find any unfinished swipes for the Current User. Potentially, the user could actually be either userOne or UserTwo
        let currentUserIsUserOneQuery = ParseSwipe.query()!
        currentUserIsUserOneQuery.whereKey("userOne", matchesQuery: innerUserQuery)
        
        let currentUserIsUserTwoQuery = ParseSwipe.query()!
        currentUserIsUserTwoQuery.whereKey("userTwo", matchesQuery: innerUserQuery)


        let orQuery = PFQuery.orQuery(withSubqueries: [currentUserIsUserOneQuery, currentUserIsUserTwoQuery])
        orQuery.includeKey("userOne")
        orQuery.includeKey("userTwo")
        orQuery.findObjectsInBackground { (objects, error) in
            //TODO: I will probably need to make this already held user thing a global variable, so when the user comes back for more users, I'll have a directory
            var swipeUserObjectIDs: [String] = [] //any user not in this array is a user that the current user has never met
            if let parseSwipes = objects as? [ParseSwipe] {
                var swipes: [Swipe] = []
                self.parseSwipes = parseSwipes
                for parseSwipe in parseSwipes {
                    let currentUserHasSwiped = parseSwipe.currentUserHasSwiped
                    let otherUser = parseSwipe.otherUser
                    let swipe = Swipe(otherUser: otherUser, otherUserApproval: parseSwipe.otherUserApproval)
                    self.alreadyUsedSwipes.append(swipe)
                    
                    if !currentUserHasSwiped  && otherUser.profileImage != nil {
                        //we only want to add to the swipe array if the user has not swiped them yet, and the other user has a profile picture. Yes, I wish I could create a query to see if the user has a profileImage, because their is no point in bringing down users that can't be used. But, this is a weakness of Parse.
                        swipes.append(swipe)
                    }
                    //if the user has swiped already, we still need add to the list of non-swipable users because we don't want the currentUser to see someone they have already swiped. Yes, it is ineffecient to pull down swipes that we never use, but that is a tradeoff of Parse.
                    swipeUserObjectIDs.append(otherUser.objectId!)
                }
                self.delegate?.passUnansweredSwipes(swipes: swipes)
            } else if let error = error {
                print(error)
            }
            //This is outside the parseSwipes area, because if the user has no swipes yet, then it won't run the for loop, so we would want to find any suers in the database. We want to find newUserSwipes regardless of whether the user has matches.
            self.getNewUserSwipes(alreadyUsedUserIDs: swipeUserObjectIDs)
        }
    }
    
    func getNewUserSwipes(alreadyUsedUserIDs: [String]) {
        //Now, we want to find all the new Users that the current user has never interacted with, or else how would the user meet new people? So, we need to find all the users who haven't been swiped yet. Kind of stinks, because we have to do two API calls (one for swipes and one for new users who weren't in swipes), but cloud code could fix that double call. Plus, we just add this to the data array, and then when the user gets to a place to reload the data (as in they hit the end of the stack, then we load more via the new user stack).
        let newUserQuery = User.query()!
        var alreadyUsedIdsCopy = alreadyUsedUserIDs
        alreadyUsedIdsCopy.append(User.current()!.objectId!) //we don't want the currentUser in their own stack
        newUserQuery.whereKey("objectId", notContainedIn: alreadyUsedIdsCopy)
        newUserQuery.whereKeyExists("profileImage")
        newUserQuery.limit = 50 //arbitrary limit, so we don't do a full table scan when there are thousands of users
        newUserQuery.findObjectsInBackground(block: { (objects, error) in
            if let users = objects as? [User] {
                if users.isEmpty {
                    self.reuseSwipes()
                } else {
                    var swipes: [Swipe] = [] //start the array over, so we can load in the new users
                    for user in users {
                        //the swipe obviously has not been approved yet by the other user, because neither user has ever made a swipe on each other.
                        let swipe = Swipe(otherUser: user, otherUserApproval: false)
                        self.alreadyUsedSwipes.append(swipe)
                        swipes.append(swipe)
                    }
                    self.delegate?.passNewUserSwipes(swipes: swipes)
                }
            } else if let error = error {
                print(error)
            }
        })
    }
    
    fileprivate func reuseSwipes() {
        //If we can't find anymore users, then we are just going to regurgitate the same users that have already been swiped. When the app doesn't have many users, it's possible for a user to swipe through all the users in the database. When, there are 1000s of users, then this function would just go grab more users. But, at least a user can keep swiping with this implementation.
        self.delegate?.passNewUserSwipes(swipes: alreadyUsedSwipes)
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
    func passNewUserSwipes(swipes: [Swipe])
}

extension BackgroundAnimationViewController: BackgroundAnimationDataStoreDelegate {
    func passUnansweredSwipes(swipes: [Swipe]) {
        self.swipeArray = swipes
        self.kolodaView.dataSource = self
        self.kolodaView.reloadData()
    }
    
    func passNewUserSwipes(swipes: [Swipe]) {
        //Don't have kolodaView reloadData because if we did, then it would restart the stack, and the user might be in the middle of the stack. Let them get to the end, then the data will be reloaded, and here, we have set the data already so the new users will be loaded. Plus, while the user is still swiping it gave time for the API call to happen, so the swiping user didn't even realzie they were swiping. Daniel Jones is an iOS god!
        let reloadData = self.swipeArray.isEmpty
        for swipe in swipes {
            //TODO: this will keep already swiped users in the array, so at some point, i'll have to make a datastore function that gets users that haven't been seen yet.
            self.swipeArray.append(swipe)
        }
        if reloadData {
            //we only want to reload the data, if the swipe array was previously empty because that means that no swipes were loaded, because the user did not have any swipes. Hence, we need to reload the data because the user has no way to reach the end of their stack to reload their data and bring up the new users.
            self.kolodaView.dataSource = self
            self.kolodaView.reloadData()
        }
    }
    
}
