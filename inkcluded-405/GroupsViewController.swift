//
//  GroupsViewController.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit
//import FBSDKCoreKit
//import FBSDKLoginKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var groupsTableView: UITableView!
    
    var groups : [Group]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //self.performSegue(withIdentifier: "showLogin" , sender: self)
        
        //wait
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "groupsCell") as! GroupsTableViewCell
        print("ffff")
        if (appdelegate.client?.currentUser != nil) {
            
            let userEntry = appdelegate.userEntry as! [AnyHashable : String]
            let group = self.groups?[indexPath.row];
            let names: [String] = (group?.members.map({ (member) -> String in
                return member.firstName}))!
            let finalNames = names.filter { (name) -> Bool in
                return name != userEntry[AnyHashable("firstname")];
        }
        
        cell.groupName.text = group?.groupName
        cell.groupDetails.text = finalNames.joined(separator: ", ")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if (appDelegate.userEntry == nil) {
            self.performSegue(withIdentifier: "showLogin" , sender: self)
        }
        if (appDelegate.userEntry != nil) {
            appDelegate.apiWrapper = APIWrapper()
            self.groups = appDelegate.apiWrapper?.getAllGroups()
        }
    }
    
    @IBAction func createNewMessage(_ sender: Any) {
        // TODO: This does nothing because Christopher has no idea what he's
        //  doing Will fix later.
    }
}
