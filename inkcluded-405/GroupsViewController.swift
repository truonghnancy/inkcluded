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

class GroupsViewController: UIViewController {
    
    @IBOutlet var groupsTableView: UITableView!
    
    let apiWrapper: APIWrapper = APIWrapper()
    var groups : [Group]?
    var menuView: UIView?
    var menuOpen: Bool = false
    let menuSize: CGFloat = 0.8
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groups = apiWrapper.getAllGroups()
        
        // making the menu view
        menuView = UITableView.init(frame: CGRect(x: -(self.view.frame.width*menuSize),
                                                  y: 0.0,
                                                  width: self.view.frame.width*menuSize,
                                                  height: self.view.frame.height))
        
        self.view.addSubview(menuView!)
        
        // create & add the screen edge gesture recognizer to open the menu
        let edgePanGR = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleEdgePan(recognizer:)))
        edgePanGR.edges = .left
        self.view.addGestureRecognizer(edgePanGR)
        
        //create & add the tap gesutre recognizer to close the menu
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        /*
        if (appDelegate.client?.currentUser == nil){
            self.performSegue(withIdentifier: "showLogin" , sender: self)
        }*/
        
    }
    
    // BUTTON ACTION
    @IBAction func menuTapped(_ sender: UIButton) {
        openMenu()
    }
    
    @IBAction func createNewMessage(_ sender: Any) {
        // TODO: This does nothing because Christopher has no idea what he's
        //  doing Will fix later.
    }
}

extension GroupsViewController: UIGestureRecognizerDelegate {
    // GESTURE RECOGNIZERS
    func handleEdgePan(recognizer: UIScreenEdgePanGestureRecognizer) {
        // open animation of menu
        self.openMenu()
        
        // TODO: should also disable all buttons on the groups view
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        // check if menu is expanded & if tap is in correct area
        let point = recognizer.location(in: self.view)
        if (menuOpen && point.x >= (self.view.frame.width*menuSize)){
            // close the menu
            self.closeMenu()
        }
    }
    
    // ANIMATIONS
    func closeMenu() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuView!.frame.origin.x = -(self.view.frame.width*self.menuSize)
        }, completion: { finished in
            self.menuOpen = false
        })
    }
    
    func openMenu() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuView!.frame.origin.x = CGPoint.zero.x
        }, completion: { finished in
            self.menuOpen = true
        })
    }
}

extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
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
}
