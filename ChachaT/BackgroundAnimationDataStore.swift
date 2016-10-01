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
    func likePerson(_ user : User) {
        matchUser(User.current()!, user2: user, isMatch: true)
    }
    
    func nopePerson(_ user : User) {
        matchUser(User.current()!, user2: user, isMatch: false)
    }
    
    fileprivate func matchUser(_ user1 : User, user2 : User, isMatch : Bool) {
        let match = Match()
        match.currentUser = user1
        match.targetUser = user2
        match.isMatch = isMatch
        
        checkMatch(match)
    }
    
    fileprivate func checkMatch(_ theMatch : Match) {
        if theMatch.isMatch {
            let matchQuery = Match.query()!
            matchQuery.whereKey(Constants.currentUser, equalTo: theMatch.targetUser)
            matchQuery.whereKey(Constants.targetUser, equalTo: theMatch.currentUser)
            matchQuery.whereKey(Constants.isMatch, equalTo: true)
            
            matchQuery.getFirstObjectInBackground(block: { (match, error) -> Void in
                var mutualMatch = false
                if let foundMatch = match as? Match {
                    self.createMatchAlert(theMatch.targetUser.fullName)
                    mutualMatch = true
                    foundMatch.mutualMatch = mutualMatch
                    foundMatch.saveInBackground()
                } else if (error != nil) {
                    print("ignore the error above becuase it just means the user did not find a match. It's not an error, just no match for the Match query")
                }
                self.updateOrInsertMatch(theMatch, mutualMatch: mutualMatch)
            })
        } else {
            updateOrInsertMatch(theMatch, mutualMatch: false)
        }
    }
    
    fileprivate func updateOrInsertMatch(_ theMatch : Match, mutualMatch : Bool) {
        // Create a query on Match
        let query = Match.query()!
        // The query has two clauses - currentUser is the current user,
        // targetUser is the match's target user (use the Constants file)
        query.whereKey(Constants.currentUser, equalTo: theMatch.currentUser)
        query.whereKey(Constants.targetUser, equalTo: theMatch.targetUser)
        
        // Get the first object (in the background).  If a match is found, update
        // that record with the proper isMatch and mutualMatch values and save it.
        // If a match is not found, update the mutualMatch value of the
        // theMatch parameter and save that.
        query.getFirstObjectInBackground { (match, error) -> Void in
            if let foundMatch = match as? Match {
                foundMatch.isMatch = theMatch.isMatch
                foundMatch.mutualMatch = mutualMatch
                foundMatch.saveInBackground()
            } else {
                theMatch.mutualMatch = mutualMatch
                theMatch.saveInBackground()
            }
        }
    }
    
    fileprivate func createMatchAlert(_ targetUserName: String?) {
        if let targetUserName = targetUserName {
            _ = SCLAlertView().showInfo("Match!", subTitle: "You matched with \(targetUserName)")
        } else {
            _ = SCLAlertView().showInfo("Match!", subTitle: "You have a match!")
        }
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
        let query = Tags.query()
        query?.whereKey("createdBy", equalTo: User.current()!)
        //there should only be one object in the background anyway. 
        query?.getFirstObjectInBackground(block: { (object, error) in
            if let tag = object as? Tags, error == nil {
                tag.location = PFGeoPoint(location: location)
                tag.saveInBackground()
            } else {
                let code = error!._code
                if code == PFErrorCode.errorObjectNotFound.rawValue{
                    //the tag doesn't exist yet for this user, so create it.
                    let newTag = Tags()
                    newTag.location = PFGeoPoint(location: location)
                    newTag.createdBy = User.current()!
                    newTag.saveInBackground()
                } else {
                    print(error)
                }
            }
        })
    }
}
