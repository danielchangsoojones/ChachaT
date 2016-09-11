//
//  DataStore.swift
//  ElevenDates
//
//  Created by Brett Keck on 9/16/15.
//  Copyright © 2015 Brett Keck. All rights reserved.
//

import UIKit
import SCLAlertView

protocol MatchDataStoreDelegate {
    func passMatchedUsers(matchedUsers: [User])
    func passChats(chats: [Chat])
}

class MatchDataStore: NSObject {
    static let sharedInstance = MatchDataStore()
    
    var delegate: MatchDataStoreDelegate?
    let currentUser = User.currentUser()!
    
    override init() {
        super.init()
    }
    
    init(delegate: MatchDataStoreDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    func likePerson(user : User) {
        matchUser(User.currentUser()!, user2: user, isMatch: true)
    }
    
    func nopePerson(user : User) {
        matchUser(User.currentUser()!, user2: user, isMatch: false)
    }
    
    private func matchUser(user1 : User, user2 : User, isMatch : Bool) {
        let match = Match()
        match.currentUser = user1
        match.targetUser = user2
        match.isMatch = isMatch
        
        checkMatch(match)
    }
    
    private func checkMatch(theMatch : Match) {
        if theMatch.isMatch {
            let matchQuery = Match.query()!
            matchQuery.whereKey(Constants.currentUser, equalTo: theMatch.targetUser)
            matchQuery.whereKey(Constants.targetUser, equalTo: theMatch.currentUser)
            matchQuery.whereKey(Constants.isMatch, equalTo: true)
            
            matchQuery.getFirstObjectInBackgroundWithBlock({ (match, error) -> Void in
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
    
    private func updateOrInsertMatch(theMatch : Match, mutualMatch : Bool) {
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
        query.getFirstObjectInBackgroundWithBlock { (match, error) -> Void in
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
    
    private func createMatchAlert(targetUserName: String?) {
        if let targetUserName = targetUserName {
            SCLAlertView().showInfo("Match!", subTitle: "You matched with \(targetUserName)")
        } else {
            SCLAlertView().showInfo("Match!", subTitle: "You have a match!")
        }
    }
    
    func findMatchedUsers() {
        var matchedUsers : [User] = []
        let query = Match.query()!
        query.whereKey(Constants.currentUser, equalTo: User.currentUser()!)
        query.whereKey(Constants.mutualMatch, equalTo: true)
        query.includeKey(Constants.targetUser)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let matches = objects as? [Match] where error == nil {
                for match in matches {
                    matchedUsers.append(match.targetUser)
                }
                self.delegate?.passMatchedUsers(matchedUsers)
            } else {
                print(error)
            }
        }
    }
    
    //TODO: figure out which chats have not been read yet, and how to group chats of the same name to the same message cell, as in we don't need two cells for a message sent from the same person.
    //TODO: get the count number for each message cell
    //
    //Purpose: This finds the chat rooms for the currentUser. It only gets the first message of a chat room, and then passes that newest chat to the view controller. We only want one cell per chat room, so even if two users have 50 messages together, we don't want 50 cells. Just one cell with the newest message.
    func findChatRooms() {
        var chatsArray : [Chat] = []
        var chatRooms : [String] = []
        let query = Chat.query()!
        query.includeKey("sender")
        query.whereKey("chatRoom", containsString: currentUser.objectId!)
        query.addDescendingOrder("createdAt") //we want the newest message for the preview message
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let chats = objects as? [Chat] where error == nil {
                for chat in chats {
                    if !chatRooms.contains(chat.chatRoom) {
                        chatRooms.append(chat.chatRoom)
                        chatsArray.append(chat)
                    }
                }
            } else {
                print("error")
            }
            self.delegate?.passChats(chatsArray)
        }
    }
}









