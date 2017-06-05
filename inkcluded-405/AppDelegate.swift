//
//  AppDelegate.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/11/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit
import EBForeNotification

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let apiCalls = APICalls.sharedInstance
        
        if url.scheme?.lowercased() == "inkcluded-405" {
            return (apiCalls.client.resume(with: url as URL))
        }
        else {
            return false
        }
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        
        print("second one called")
        
        let apiCalls = APICalls.sharedInstance
        
        print("client " + String(describing: apiCalls.client))
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        NSLog("%@", userInfo)
        
        if userInfo["aps"] != nil && (userInfo["aps"] as! [AnyHashable : Any])["groupId"] != nil && (userInfo["aps"] as! [AnyHashable : Any])["messageId"] != nil {
            let groupid = (userInfo["aps"] as! [AnyHashable : Any])["groupId"]
            let messageid = (userInfo["aps"] as! [AnyHashable : Any])["messageId"]
            var groupname : String = ""
            var sentuser : String = ""
            var found = false
            let myDispatchGroup = DispatchGroup()
            
            
            APICalls.sharedInstance.getGroupsAPI(sid: APICalls.sharedInstance.currentUser!.id, closure: {
                (groups) in
                
                for g in groups! {
                    if g.id == groupid as! String {
                        groupname = g.groupName
                        
                        myDispatchGroup.enter()
                        APICalls.sharedInstance.getAllMessage(groupId: g.id, closure: {
                            (messages) in
                            
                            for m in g.messages {
                                if m.filename == messageid as! String {
                                    sentuser = m.senderfirstname
                                }
                            }
                            found = true
                            myDispatchGroup.leave()
                        })
                        
                    }
                }
                myDispatchGroup.notify(queue: .main, execute: {
                    if found {
                        let pushdict = ["aps" : ["alert" : "Message received from group " + groupname + " by " + sentuser]]
                        if #available(iOS 10, *) {
                            EBForeNotification.handleRemoteNotification(pushdict, soundID: 1312, isIos10: true)
                        }
                        else {
                            EBForeNotification.handleRemoteNotification(pushdict, soundID: 1312)
                        }
                    }
                })
                
            })
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let hub = SBNotificationHub(connectionString: HUBLISTENACCESS, notificationHubPath: HUBNAME)
        
        hub?.registerNative(withDeviceToken: deviceToken, tags: nil) {
            (error) -> Void in
            
            if (error != nil) {
                print("Error registering for notifications:", error!)
            }
            else {
                print("Registered")
            }
            
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

