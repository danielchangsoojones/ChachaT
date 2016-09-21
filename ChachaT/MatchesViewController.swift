//
//  MatchesViewController.swift
//  ChachaT
//
//  Created by Daniel Jones on 7/23/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController {
    private struct MatchesConstants {
        static let numberOfSections : Int = 2
        static let heightForSectionHeader : CGFloat = 40
        static let sectionZeroHeadingTitle : String = "Matches"
        static let sectionOneHeadingTitle : String = "Messages"
    }
    
    @IBOutlet weak var theTableView: UITableView!
    var matches : [Connection] = []
    var chats : [Chat] = []
    var dataStore : MatchDataStore!
    
    //go to messages page
    @IBAction func theButtonPressed(sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBarHidden = false
        dataStoreSetup()
    }
    
    func dataStoreSetup() {
        dataStore = MatchDataStore(delegate: self)
        dataStore.findMatchedUsers()
        dataStore.findChatRooms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //the matches area
            return 1
        } else {
            //the messaging area
            return chats.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return MatchesConstants.numberOfSections
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MatchesConstants.heightForSectionHeader
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            //the matches area
            //TODO: make the notification number based upon the number of new matches. Not the total
            let notificationNumber = matches.count
            let headingView = HeadingView(text: MatchesConstants.sectionZeroHeadingTitle, notificationNumber: notificationNumber)
            return headingView
        } else if section == 1 {
            //the messaging area
            //TODO: the notification number should really be the number of total chats. So, if another user sent 30 messages, it only shows up as one chat cell, but it should still have a total count of 20. So, that means we have to pass an array of chats from dataStore that are in another array called samePersonNotification or something.
            let notificationNumber = chats.count
            let headingView = HeadingView(text: MatchesConstants.sectionOneHeadingTitle, notificationNumber: notificationNumber)
            return headingView
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentRow = indexPath.row
        let currentSection = indexPath.section
        if currentSection == 0 {
            //the matches area
            let matchesCell = ScrollingMatchesTableViewCell(matches: matches, delegate: self)
            return matchesCell
        } else {
            //the messages area
            let currentChat = chats[currentRow]
            let chatCell = ChatTableViewCell(chat: currentChat)
            return chatCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentRow = indexPath.row
        let currentSection = indexPath.section
        if currentSection == 1 {
            //the messaging area
            let currentChat = chats[currentRow]
            currentChat.readByReceiver = true //after they click the cell to see messages, then that means they have read it.
            currentChat.saveInBackground()
            //the otherUser should be whichever one the currentUser is not
            let otherUser : User = currentChat.sender == User.currentUser() ? currentChat.receiver : currentChat.sender
            segueToChatVC(otherUser)
        }
    }
}

extension MatchesViewController : ScrollingMatchesCellDelegate {
    func segueToChatVC(otherUser: User) {
        let chatVC = ChatViewController()
        chatVC.currentUser = User.currentUser()
        chatVC.otherUser = otherUser
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
