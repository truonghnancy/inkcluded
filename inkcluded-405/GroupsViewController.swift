//
//  GroupsViewController.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

enum menuState {
    case Expanded
    case Collapsed
}

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet var groupsTableView: UITableView!
    
    var groups : [Group]?
    var menuView: UIView?
    var menuState: menuState = .Collapsed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.groups = appDelegate.apiWrapper?.groupList
        
        // making the menu view
        menuView = UIView.init(frame: CGRect(x: -400, y: 0, width: 400, height: self.view.frame.height))
        menuView!.backgroundColor = UIColor.black
        
        self.view.addSubview(menuView!)
        
        // create & add the screen edge gesture recognizer to open the menu
        let edgePanGR = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleEdgePan(recognizer:)))
        edgePanGR.edges = .left
        edgePanGR.delegate = self
        self.view.addGestureRecognizer(edgePanGR)
        
        //create & add the tap gesutre recognizer to close the menu
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)))
        tapGR.delegate = self
        self.view.addGestureRecognizer(tapGR)
    }
    
    
    // GESTURE RECOGNIZERS
    func handleEdgePan(recognizer: UIScreenEdgePanGestureRecognizer) {
        // open animation of menu
        self.openMenu()
        
        // TODO: should also disable all buttons on the groups view
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        // check if menu is expanded & if tap is in correct area
        let point = recognizer.location(in: self.view)
        if (menuState == .Expanded && point.x >= 300){
            // close the menu
           self.closeMenu()
        }
    }
    
    // ANIMATIONS
    func closeMenu() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuView!.frame.origin.x = -400 // <= replace this magic number
        }, completion: { finished in
            self.menuState = .Collapsed
            print("state: \(self.menuState)")
        })
    }
    
    func openMenu() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuView!.frame.origin.x = -100 // <= replace this magic number
        }, completion: { finished in
            self.menuState = .Expanded
        })
    }
    
    // BUTTON ACTION
    @IBAction func menuTapped(_ sender: UIButton) {
        if (menuState == .Collapsed) {
            openMenu()
            menuState = .Expanded
        } else {
            closeMenu()
            menuState = .Collapsed
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups!.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "groupsCell") as! GroupsTableViewCell
        print("ffff")
        if (appdelegate.apiWrapper?.client.currentUser != nil) {
            
            let userEntry = appdelegate.apiWrapper?.userEntry as! [AnyHashable : String]
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
        
        if (appDelegate.apiWrapper?.userEntry == nil) {
            super.viewDidAppear(animated)
            self.performSegue(withIdentifier: "showLogin" , sender: self)
            self.groups = appDelegate.apiWrapper?.groupList
        }
        else {
            self.groups = appDelegate.apiWrapper?.groupList
            
        }
    }
    
    @IBAction func createNewMessage(_ sender: Any) {
        // TODO: This does nothing because Christopher has no idea what he's
        //  doing Will fix later.
    }
}
