//
//  LoginViewController.swift
//  bobaoauth
//
//  Created by Eric on 1/15/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import UIKit
import CoreData
//import FBSDKCoreKit
//import FBSDKLoginKit

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

    func loginAndGetData(oauthType: String) {
        print("\t\tIn loginAndGetData")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        print("appDelegate data " + String(describing: appDelegate))
        print("client data " + String(describing: appDelegate.client))
        
        guard let client = appDelegate.client, client.currentUser?.userId == nil else {
            print("returning " + String(describing: appDelegate.client?.currentUser?.userId))
            return
        }
        
        let loginBlock: MSClientLoginBlock = {(user, error) -> Void in
            if (error != nil) {
                print("Error message: \(error?.localizedDescription)")
            }
            else {
                client.currentUser = user
                print("User logged in: \(user?.userId)")
                self.addUserToDatabase(client: client)
                self.dismiss(animated: true, completion: nil)
            }
        }
        print("passed all this")

        client.login(withProvider: oauthType, urlScheme: "inkcluded-405", controller: self, animated: true, completion: loginBlock)
        print("login: " + String(describing: client.currentUser))
    }
    
    func addUserToDatabase(client : MSClient) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let sid = client.currentUser?.userId
        let userTable = client.table(withName: "User")
        let query = userTable.query(with: NSPredicate(format: "id = %@", sid!))
        var userEntry = appDelegate.userEntry
        
        query.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if result?.items?.count == 0 {
                userTable.insert(["id" : sid!]) { (result, error) in
                    if error != nil {
                        print(error!)
                    } else  {
                        userEntry = result as! AnyHashable
                    }
                }
            } else if let items = result?.items {
                userEntry = result!
                print(items)
            }
        }
    }
   

}
