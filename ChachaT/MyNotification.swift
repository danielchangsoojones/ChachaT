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
    
    
    func checkIfStartedFromNotification(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
//            let prefs: UserDefaults = UserDefaults.standard
//            prefs.set(remoteNotification as! [AnyHashable: Any], forKey: "startUpNotif")
//            prefs.synchronize()
            if let dict = remoteNotification as? [AnyHashable : Any] {
                getNotificationIdentifier(dictionary: remoteNotification)
            }
            
            
            
            let query = User.query()!
            query.getFirstObjectInBackground(block: { (object, error) in
                let navController = UIApplication.shared.keyWindow?.rootViewController as! ChachaNavigationViewController
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as! CardDetailViewController
                initialViewController.userOfTheCard = object as! User
                
                navController.pushViewController(initialViewController, animated: false)
                
//                window.rootViewController = initialViewController
//                window.makeKeyAndVisible()
            })
            
            return true
        }
        return false
    }
    
    func helper() {
        let query = User.query()!
        query.getFirstObjectInBackground(block: { (object, error) in
            let navController = UIApplication.shared.keyWindow?.rootViewController as! ChachaNavigationViewController
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as! CardDetailViewController
            initialViewController.userOfTheCard = object as! User
            
            navController.pushViewController(initialViewController, animated: false)
            
            //                window.rootViewController = initialViewController
            //                window.makeKeyAndVisible()
        })
    }
    
    fileprivate func getNotificationIdentifier(dictionary: [AnyHashable: Any]) -> Identifier? {
        if let dict = dictionary as? [AnyHashable: Any], let value = dict["identifier"] as? String, let identifier = Identifiers(rawValue: value) {
            switch identifier {
            case .toMatch:
                print(identifier.rawValue)
            }
        }
        return nil
    }
}

//App was completely closed
extension MyNotification {
    func enteringAppActions(identifier: Identifier) {
        
    }
}






