//
//  LoginViewController.swift
//  bobaoauth
//
//  Created by Eric on 1/15/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController,  FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let loginFBButton = FBSDKLoginButton()
        loginFBButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginFBButton.center = self.view.center
        
        loginFBButton.delegate = self
        
        self.view.addSubview(loginFBButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error == nil && result.token != nil
        {
            print("Logged in")
            UserDefaults.standard.set(result.token.tokenString, forKey: "oauthKey")
            UserDefaults.standard.synchronize()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("user logged out")
        UserDefaults.standard.removeObject(forKey: "oauthKey")
    }


}
