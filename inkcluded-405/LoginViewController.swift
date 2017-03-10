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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        print("appDelegate data " + String(describing: appDelegate))
        print("client data " + String(describing: appDelegate.apiWrapper?.client))
        
        appDelegate.apiWrapper?.client.login(withProvider: oauthType, urlScheme: "inkcluded-405", controller: self, animated: true, completion:
            {(user, error) -> Void in
                if (error != nil) {
                    print("Error message: \(error?.localizedDescription)")
                }
                else {
                    appDelegate.apiWrapper?.client.currentUser = user
                    print("User logged in: \(user?.userId)")
                    appDelegate.apiWrapper?.login(closure:
                        {(userEntry) -> Void in
                            if (userEntry == nil) {
                                
                            }
                            else {
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        })
                }
        })
    }
}
