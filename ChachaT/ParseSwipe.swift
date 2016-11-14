//
//  ParseSwipe.swift
//  ChachaT
//
//  Created by Daniel Jones on 10/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
import Parse

class ParseSwipe: PFObject, PFSubclassing {
    class func parseClassName() -> String {
        return "ParseSwipe"
    }
    
    @NSManaged var userOne: User
    @NSManaged var userTwo: User
    @NSManaged var userOneApproval: Bool
    @NSManaged var userTwoApproval: Bool
    @NSManaged var hasUserOneSwiped: Bool
    @NSManaged var hasUserTwoSwiped: Bool
    @NSManaged var userOneMessage: String?
    @NSManaged var userTwoMessage: String?
    //returns the user in the match that is not the currentUser
    var otherUser: User {
        get {
            let userNumber = whichUserIsCurrentUser()
            if userNumber == 1 {
                return userTwo
            } 
            return userOne
        }
    }
    var otherUserApproval: Bool {
        get {
            let userNumber = whichUserIsCurrentUser()
            if userNumber == 1 {
                return userTwoApproval
            }
            return userOneApproval
        }
    }
    var currentUserApproval: Bool {
        get {
            let userNumber = whichUserIsCurrentUser()
            if userNumber == 1 {
                return userOneApproval
            }
            return userTwoApproval
        }
        set (hasApproved) {
            let userNumber = whichUserIsCurrentUser()
            if userNumber == 1 {
                userOneApproval = hasApproved
            } else if userNumber == 2 {
                userTwoApproval = hasApproved
            }
        }
    }
    var currentUserHasSwiped: Bool {
        get {
            let userNumber = whichUserIsCurrentUser()
            if userNumber == 1 {
                return hasUserOneSwiped
            } 
            return hasUserTwoSwiped
        }
        set (hasSwiped) {
            //when we set the currentUserHasSwiped, we want to find what user is the currentuser and then set the appropriate hasSwiped
            let userNumber = whichUserIsCurrentUser()
            if userNumber == 1 {
                hasUserOneSwiped = hasSwiped
            } else if userNumber == 2 {
                hasUserTwoSwiped = hasSwiped
            }
        }
    }
    
    override init() {
        //have to override init, or else Parse gets mad. 
        super.init()
    }
    
    //When we want to create a new ParseSwipe, we just need to know if the currentUser approved, and who the other user is, then we can set everything else accordingly.
    convenience init(otherUser: User, currentUserApproval: Bool) {
        //set the current user to userOne, doesn't technically matter which user we set it to.
        self.init()
        userOne = User.current()!
        userOneApproval = currentUserApproval
        hasUserOneSwiped = true
        
        //set the otherUser to userTwo
        userTwo = otherUser
        userTwoApproval = false
        hasUserTwoSwiped = false
    }
    
    func whichUserIsCurrentUser() -> Int {
        if userOne.objectId == User.current()!.objectId! {
            return 1
        } else if userTwo.objectId! == User.current()!.objectId! {
            return 2
        }
        return 0 //the currentUser is neither of the users. It should never reach this point.
    }
    
    //Purpose: gets passed a other user to see if this swipe matches
    func matchesUsers(otherUser: User) -> Bool {
        let currentUserMatch = User.current()!.objectId! == userOne.objectId! || User.current()!.objectId! == userTwo.objectId!
        let otherUserMatch = otherUser.objectId! == userOne.objectId! || otherUser.objectId! == userTwo.objectId!
        return currentUserMatch && otherUserMatch
    }
}
