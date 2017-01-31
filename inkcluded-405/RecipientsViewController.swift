//
//  RecipientsViewController.swift
//  inkcluded-405
//
//  Created by Christopher on 1/30/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class RecipientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        return 0;
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        return UITableViewCell();
    }
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        
        //        if (FBSDKAccessToken.current() == nil)
        //        {
        //            self.performSegue(withIdentifier: "showLogin" , sender: self)
        //        }
        print("help")
        
    }
    
}

