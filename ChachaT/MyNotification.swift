//
//  Notification.swift
//  ChachaT
//
//  Created by Daniel Jones on 12/3/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import Foundation
//TODO: make a datastore for this class
import Parse

class MyNotification {
    //Don't change identifier names, unless we change the names of the identifiers in the server code also.
    enum Identifier: String {
        case toMatch
    }
    
    var dataStore: MyNotificationDataStore!
    
    init() {
        dataStore = MyNotificationDataStore(delegate: self)
    }
    
    
    func checkIfStartedFromNotification(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
            performAction(dict: remoteNotification, appStatus: .inactive)
            return true
        }
        return false
    }
    
    func performAction(dict: [AnyHashable : Any], appStatus: UIApplicationState) {
        if let identifier = getNotificationIdentifier(dictionary: dict) {
            switch appStatus {
            case .active:
                break
            case .inactive, .background:
                enteringAppActions(identifier: identifier, dictionary: dict)
            }
        }
    }
    
    fileprivate func getNotificationIdentifier(dictionary: [AnyHashable: Any]) -> Identifier? {
        if let value = dictionary["identifier"] as? String {
            return Identifier(rawValue: value)
        }
        return nil
    }
}

//App was completely closed
extension MyNotification {
    fileprivate func enteringAppActions(identifier: Identifier, dictionary: [AnyHashable : Any]) {
        switch identifier {
        case .toMatch:
            showNotifiedMatch(dictionary: dictionary)
        }
    }
    
    fileprivate func showNotifiedMatch(dictionary: [AnyHashable : Any]) {
        let parseSwipeObjectId: String? = dictionary["objectId"] as? String
        dataStore.findNewMatchFromParseSwipe(objectId: parseSwipeObjectId ?? "")
    }
}

//Segueing to chat actions
extension MyNotification: MyNotificationDataStoreDelegate {
    func segueToChat(connection: Connection) {
        if let navController = getCurrentNavController() {
            let chatVC = ChatViewController.instantiate(connection: connection)
            navController.pushViewControllers(viewControllers: [getMatchesVC(), chatVC])
        }
    }
    
    fileprivate func getMatchesVC() -> MatchesViewController {
        let matchesVC = instatiateVC(storyboardId: "Matches", viewControllerId: "MatchesViewController") as! MatchesViewController
        return matchesVC
    }
    
    fileprivate func instatiateVC(storyboardId: String, viewControllerId: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardId, bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: viewControllerId)
        return initialViewController
    }
    
    fileprivate func getCurrentNavController() -> ChachaNavigationViewController? {
        return UIApplication.shared.keyWindow?.rootViewController as? ChachaNavigationViewController
    }
}






