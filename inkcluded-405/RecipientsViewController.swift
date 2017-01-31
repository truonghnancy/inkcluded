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
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    let apiWrapper: APIWrapper = APIWrapper()
    var friends : [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friends = apiWrapper.getFriendsList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends!.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.friendsTableView.dequeueReusableCell(withIdentifier: "friendCell") as! GroupsTableViewCell
        let friend = self.friends?[indexPath.row];
        let names: [String] = (group?.members.map({ (memberId) -> String in
            return apiWrapper.getFriendById(userId: memberId).firstName;
        }))!
        let finalNames = names.filter { (name) -> Bool in
            return name != self.apiWrapper.getCurrentUser().firstName;
        }
        
        cell.groupName.text = friend?.firstName + " " + friend?.lastName
        cell.groupDetails.text = finalNames.joined(separator: ", ")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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

