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

enum menuState {
    case Expanded
    case Collapsed
}

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet var groupsTableView: UITableView!
    
    let apiWrapper: APIWrapper = APIWrapper()
    var groups : [Group]?
    var menuView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groups = apiWrapper.getAllGroups()
        
        // making the menu view
        menuView = UIView.init(frame: CGRect(x: -400, y: 0, width: 400, height: self.view.frame.height))
        menuView!.backgroundColor = UIColor.black
        self.view.addSubview(menuView!)
        
        // create & add the screen edge gesture recognizer
        let edgePanGR = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleEdgePan(recognizer:)))
        edgePanGR.edges = .left
        edgePanGR.delegate = self
        self.view.addGestureRecognizer(edgePanGR)
        
        // create & add the pan gesture recognizer
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        panGR.delegate = self
        menuView!.addGestureRecognizer(panGR)
        
        //create & add the tap gesutre recognizer
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
        tapGR.delegate = self
        self.view.addGestureRecognizer(tapGR)
        
    }
    
    func handleEdgePan(recognizer: UIScreenEdgePanGestureRecognizer) {
        // animation of menu
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.menuView!.frame.origin.x = -60
        }, completion: { finished in
            print("Yay animation!")
        })
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if (appDelegate.client?.currentUser == nil){
            self.performSegue(withIdentifier: "showLogin" , sender: self)
        }
        
    }
    
    @IBAction func createNewMessage(_ sender: Any) {
        // TODO: This does nothing because Christopher has no idea what he's
        //  doing Will fix later.
    }
}
