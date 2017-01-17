//
//  GroupsViewController.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class GroupsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        print("\t\t hello")
        print(UserDefaults.standard.object(forKey: "oauthKey") ?? 1)
        if (FBSDKAccessToken.current() == nil)
//        if (UserDefaults.standard.object(forKey: "oauthKey") == nil)
        {
            print("\t\t\tnot logged in")
            self.performSegue(withIdentifier: "showLogin" , sender: self)
        }
        else
        {
            //            print(FBSDKAccessToken.currentAccessToken())
            print("logged in")
//            self.performSegue(withIdentifier: "showLogin" , sender: self)
        }
        
    }
    
    @IBAction func createNewMessage(_ sender: Any) {
        // TODO: This does nothing because Christopher has no idea what he's
        //  doing Will fix later.
    }
}
