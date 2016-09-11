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
    }
    
    @IBOutlet weak var theTableView: UITableView!
    var matchedUsers : [User] = []
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
        return 50
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, w: 300, h: 300))
        view.backgroundColor = UIColor.yellowColor()
        return view
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentRow = indexPath.row
        let currentSection = indexPath.section
        if currentSection == 0 {
            //the matches area
            let matchesCell = ScrollingMatchesTableViewCell(matchedUsers: matchedUsers, delegate: self)
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
            segueToChatVC(currentChat.receiver)
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

extension MatchesViewController: MatchDataStoreDelegate {
    func passMatchedUsers(matches: [User]) {
        matchedUsers = matches
        theTableView.reloadData()
    }
    
    func passChats(chats: [Chat]) {
        self.chats = chats
        theTableView.reloadData()
    }
}
