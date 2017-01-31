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

@objc
protocol GroupsViewControllerDelegate {
    @objc optional func toggleLeftPanel()
}

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var groupsTableView: UITableView!
    
    let apiWrapper: APIWrapper = APIWrapper()
    var groups : [Group]?
    var delegate: GroupsViewControllerDelegate?
    var containerView: ContainerViewController?
    
    @IBAction func menuTapped(_ sender: AnyObject) {
        delegate?.toggleLeftPanel?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groups = apiWrapper.getAllGroups()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups!.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "groupsCell") as! GroupsTableViewCell
        let group = self.groups?[indexPath.row];
        let names: [String] = (group?.members.map({ (memberId) -> String in
            return apiWrapper.getFriendById(userId: memberId).firstName;
        }))!
        let finalNames = names.filter { (name) -> Bool in
            return name != self.apiWrapper.getCurrentUser().firstName;
        }
    
        cell.groupName.text = group?.groupName
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
        
    }
    
    @IBAction func createNewMessage(_ sender: Any) {
        // TODO: This does nothing because Christopher has no idea what he's
        //  doing Will fix later.
    }
}
