//
//  LoginViewController.swift
//  bobaoauth
//
//  Created by Eric on 1/15/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("\t\tviewDidLoad")
        
        /* Forgive me, security experts, for I have sinned. */
        let lastLoginStr = UserDefaults.standard.string(
                            forKey: "_stylo-ios-last-login")
        if (lastLoginStr == "facebook" || lastLoginStr == "google"
            || lastLoginStr == "microsoftaccount") {
            self.loginAndGetData(oauthType: lastLoginStr!)
        }
    }

    @IBAction func facebookButtonPress(_ sender: Any) {
        self.loginAndGetData(oauthType: "facebook")
    }
    
    @IBAction func googleButtonPress(_ sender: Any) {
        self.loginAndGetData(oauthType: "google")
    }
    
    @IBAction func microsoftButtonPress(_ sender: Any) {
        self.loginAndGetData(oauthType: "microsoftaccount")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
     Log in and get data of the current user
     Josh Choi
    */
    func loginAndGetData(oauthType: String) {
        
        print("\t\tIn loginAndGetData")
        let apiCalls = APICalls.sharedInstance
        
        let loaderView = LoadView(frame: self.view.frame)
        self.view.addSubview(loaderView)
        apiCalls.client.login(withProvider: oauthType, urlScheme: "inkcluded-405", controller: self, animated: true, completion:
            {(user, error) -> Void in
                if (error != nil) {
                    print("Error message: \(error?.localizedDescription)")
                    loaderView.removeFromSuperview()
                }
                else {
                    apiCalls.client.currentUser = user
                    print("User logged in: \(user?.userId)")
                    apiCalls.login(closure:
                        {(userEntry) -> Void in
                            if (userEntry == nil) {
                                loaderView.removeFromSuperview()
                            }
                            else {
                                loaderView.removeFromSuperview()
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    
                    /* Ugh. */
                    UserDefaults.standard.set(oauthType,
                                              forKey: "_stylo-ios-last-login")
                    UserDefaults.standard.synchronize()
                }
        })
    }
}
