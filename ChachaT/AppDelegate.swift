//
//  AppDelegate.swift
//  ChachaT
//
//  Created by Daniel Jones on 5/5/16.
//  Copyright © 2016 Chong500Productions. All rights reserved.
//

import UIKit
import Parse
import Pages
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //register parse subclasses
        User.registerSubclass()
        Tags.registerSubclass()
        Match.registerSubclass()
        Chat.registerSubclass()
        
        // Override point for customization after application launch.
        let configuration = ParseClientConfiguration {
            $0.applicationId = "djflkajsdlfjienrj3457698"
            $0.server = "https://chachatinder.herokuapp.com/parse"
        }
        Parse.initializeWithConfiguration(configuration)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        Instabug.startWithToken("c1d90288be3cf98624000127f6139a87", invocationEvent: IBGInvocationEvent.Shake)
        
        //setting the initial storyboard
        if User.currentUser() == nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("SignUpLogInViewController") as! SignUpLogInViewController
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
        }
        
        //this is for easy changing of main viewcontrollers when I am working, so I don't have to click all the way to a screen
//                    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        
//                    let storyboard = UIStoryboard(name: "Matches", bundle: nil)
//        
//                    let initialViewController = storyboard.instantiateViewControllerWithIdentifier("MatchesViewController") as! MatchesViewController
//        
//                    self.window?.rootViewController = initialViewController
//                    self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }


}

