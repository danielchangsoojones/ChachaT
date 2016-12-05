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
    fileprivate struct MatchesConstants {
        static let numberOfSections : Int = 2
        static let heightForSectionHeader : CGFloat = 25
        static let sectionZeroHeadingTitle : String = "Matches"
        static let sectionOneHeadingTitle : String = "Messages"
    }
    
    @IBOutlet weak var theTableView: UITableView!
    var matches : [Connection] = []
    var chatRooms : [ChatRoom] = []
    var dataStore : MatchDataStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.isNavigationBarHidden = false
        dataStoreSetup()
        setNavigationLogoImage()
        theTableView.separatorStyle = .none
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // when they leave this screen, stop checking for messages
        dataStore.unsubscribeToLiveMessaging()
    }
    
    func dataStoreSetup() {
        dataStore = MatchDataStore(delegate: self)
        dataStore.findMatchedUsers()
        dataStore.findChatRooms()
    }
    
    func setNavigationLogoImage() {
        let logo = #imageLiteral(resourceName: "messageIcon")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationItem.titleView!.snp.makeConstraints { (make) in
            //TODO: probably should make these constants based upon something
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //the matches area
            return 1
        } else {
            //the messaging area
            return chatRooms.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MatchesConstants.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MatchesConstants.heightForSectionHeader
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            //the matches area
            //TODO: make the notification number based upon the number of new matches. Not the total
            let notificationNumber = matches.count
            let headingView = HeadingView(text: MatchesConstants.sectionZeroHeadingTitle, notificationNumber: notificationNumber)
            return headingView
        } else if section == 1 {
            //the messaging area
            //TODO: the notification number should really be the number of total chats. So, if another user sent 30 messages, it only shows up as one chat cell, but it should still have a total count of 20. So, that means we have to pass an array of chats from dataStore that are in another array called samePersonNotification or something.
            let notificationNumber = chatRooms.count
            let headingView = HeadingView(text: MatchesConstants.sectionOneHeadingTitle, notificationNumber: notificationNumber)
            return headingView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentRow = (indexPath as NSIndexPath).row
        let currentSection = (indexPath as NSIndexPath).section
        if currentSection == 0 {
            //the matches area
            let matchesCell = ScrollingMatchesTableViewCell(matches: matches, delegate: self)
            return matchesCell
        } else {
            //the messages area
            let currentChatRoom = chatRooms[currentRow]
            let chatCell = ChatTableViewCell(chatRoom: currentChatRoom)
            return chatCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentRow = (indexPath as NSIndexPath).row
        let currentSection = (indexPath as NSIndexPath).section
        if currentSection == 1 {
            //the messaging area
            let currentChatRoom = chatRooms[currentRow]
            dataStore.messagesHaveBeenRead(currentChatRoom)
            //the otherUser should be whichever one the currentUser is not
            if let otherUser = currentChatRoom.getOtherUser() {
                segueToChatVC(otherUser)
            }
        }
    }
}

extension MatchesViewController : ScrollingMatchesCellDelegate {
    func segueToChatVC(_ otherUser: User) {
        let chatVC = ChatViewController.instantiate(connection: Connection(targetUser: otherUser))
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
