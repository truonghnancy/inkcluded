//
//  AppDelegate.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/11/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import UIKit

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
    
    /**- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:HUBLISTENACCESS
    notificationHubPath:HUBNAME];
    
    [hub registerNativeWithDeviceToken:deviceToken tags:nil completion:^(NSError* error) {
    if (error != nil) {
    NSLog(@"Error registering for notifications: %@", error);
    }
    else {
    [self MessageBox:@"Registration Status" message:@"Registered"];
    }
    }];
    }
    
    -(void)MessageBox:(NSString *)title message:(NSString *)messageText
    {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:messageText delegate:self
    cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    }
    
    - (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    [self MessageBox:@"Notification" message:[[userInfo objectForKey:@"aps"] valueForKey:@"alert"]];
    }**/
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("%@", userInfo)
        self.MessageBox("Notification", message: (userInfo["aps"] as! [AnyHashable : Any])["alert"] as! String)
    }
    
    func MessageBox(_ title: String, message messageText: String) {
        let alert = UIAlertController(title: title, message: messageText, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.window?.rootViewController?.present(alert, animated: true) {
            // TODO completion block, might be some use later?
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
        
        /**SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:HUBLISTENACCESS
            notificationHubPath:HUBNAME];**/
        
        /**[hub registerNativeWithDeviceToken:deviceToken tags:nil completion:^(NSError* error) {
            if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
            }
            else {
            [self MessageBox:@"Registration Status" message:@"Registered"];
            }
            }];**/
        
        
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

//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        if url.scheme?.lowercased() == "http://penmessageapp.azurewebsites.net" {
//            return (self.client!.resume(with: url as URL))
//        }
//        else {
//            return false
//        }
//    }
    
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

