//
//  AppDelegate.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/5/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

@UIApplicationMain
//TODO: one day create datastore to hold the parse stuff
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //register parse subclasses
        User.registerSubclass()
        Chat.registerSubclass()
        ParseSwipe.registerSubclass()
        ParseTag.registerSubclass()
        DropDownCategory.registerSubclass()
        ParseUserTag.registerSubclass()
        
        var appConfiguration = Configuration()
        let configuration = ParseClientConfiguration {
            $0.applicationId = appConfiguration.environment.applicationId
            $0.server = appConfiguration.environment.server
        }
        
        Parse.initialize(with: configuration)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        
        Instabug.start(withToken: "c1d90288be3cf98624000127f6139a87", invocationEvent: IBGInvocationEvent.shake)

        if User.current() == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "SignUpLogInViewController") as! SignUpLogInViewController
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            let myNotification = MyNotification()
            myNotification.registerForNotifications(application: application)
            myNotification.checkIfStartedFromNotification(launchOptions: launchOptions)
        }
        //this is for easy changing of main viewcontrollers when I am working, so I don't have to click all the way to a screen
//                    self.window = UIWindow(frame: UIScreen.main.bounds)
//        
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
////                    let initialViewController = TutorialBackgroundAnimationViewController()
//        
//                    self.window?.rootViewController = initialViewController
//                    self.window?.makeKeyAndVisible()
        
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        MyNotification().resetNotificationBadgeCount()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MyNotification().setDeviceTokenToPoint(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //when user has app in background or is in app, it will call this when a remote notification received. If the app was in background, it waits to get the app into the foreground before calling this
        print(userInfo)
        MyNotification().performAction(dict: userInfo, appStatus: application.applicationState)
    }


}

