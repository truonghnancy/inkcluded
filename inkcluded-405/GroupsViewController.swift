//
//  GroupsViewController.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class GroupsViewController: UIViewController {
    
    @IBOutlet var groupsTableView: UITableView!
    
    var groups : [Group]?
    var selectedGroup: Group?
    var menuView: MenuView?
    var menuOpen: Bool = false
    let menuSize: CGFloat = 0.8
    var deleteGroup: NSIndexPath? = nil
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groups = []
        
        // making the menu view
        menuView = MenuView(frame: CGRect(x: -(self.view.frame.width*menuSize),
                                             y: 0.0,
                                             width: self.view.frame.width*menuSize,
                                             height: self.view.frame.height),
                            delegate: self)
        self.view.addSubview(menuView!)
        
        self.groupsTableView.addSubview(self.refreshControl)
        
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
        let apiCalls = APICalls.sharedInstance
        
        if (apiCalls.currentUser == nil) {
            super.viewDidAppear(animated)
            self.performSegue(withIdentifier: "showLogin" , sender: self)
            self.groups = apiCalls.groupList
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let apiCalls = APICalls.sharedInstance
        if (apiCalls.currentUser != nil && (groups?.isEmpty)!) {
            let loadView = LoadView(frame: self.view.frame)
            self.view.addSubview(loadView)
            apiCalls.getGroupsAPI(sid: apiCalls.currentUser!.id, closure: { (groupList) in
                self.groups = groupList
                self.groupsTableView.reloadData()
                loadView.removeFromSuperview()
            })
        }
    }
    
    
    // BUTTON ACTION
    @IBAction func menuTapped(_ sender: UIBarButtonItem) {
        if (menuOpen) {
            closeMenu()
        }
        else {
            openMenu()
        }
    }
}

extension GroupsViewController: MenuViewDelegate {
    func didClickOnFeedbackButton() {
        UIApplication.shared.open(URL(string: "https://stylo-9092d.firebaseapp.com")!, options: [:]) { (isSuccessful) in
            if (!isSuccessful) {
                print("nooo")
            }
        }
    }
    
    // TODO: make a confirmation popup
    // need to figure out a way to refresh the groups after logging back in as a different user
    func didClickOnLogoutButton() {
        APICalls.sharedInstance.logout()
        print("logged out")
        
        self.performSegue(withIdentifier: "showLogin" , sender: self)
        closeMenu()
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
        groupsTableView.isUserInteractionEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuView!.frame.origin.x = -(self.view.frame.width*self.menuSize)
        }, completion: { finished in
            self.menuOpen = false
        })
    }
    
    func openMenu() {
        groupsTableView.isUserInteractionEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
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
        
        let members = group?.members.map({ (member) -> String in
            return member.firstName
        })
        
        cell.groupName.text = group?.groupName
        cell.groupDetails.text = members?.joined(separator: ", ")
        
        return cell
    }
    
    func handleRefresh() {
        let loadView = LoadView(frame: self.view.frame)
        self.view.addSubview(loadView)
        
        let apiCalls = APICalls.sharedInstance
        apiCalls.getGroupsAPI(sid: apiCalls.currentUser!.id, closure: { (groupList) in
            self.groups = groupList
            self.groupsTableView.reloadData()
            loadView.removeFromSuperview()
        })
        self.refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteGroup = indexPath as NSIndexPath?
            let groupselect = groups![deleteGroup!.row].id
            print(groupselect)
            
            tableView.beginUpdates()
            let apiCalls = APICalls.sharedInstance
            groups?.remove(at: deleteGroup!.row)
            
            apiCalls.leaveGroup(groupId: groupselect)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            deleteGroup = nil
            
            tableView.endUpdates()
        }
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            deleteGroup = indexPath
//            let planetToDelete = groups?[indexPath.row]
//            confirmDelete(planet: planetToDelete)
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set the selected group and segue to the group history view.
        self.selectedGroup = groups?[indexPath.row]
        self.performSegue(withIdentifier: "viewHistorySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If we're segueing to the group history view, set the selected group.
        if (segue.identifier == "viewHistorySegue") {
            let dest: GroupHistoryViewController = segue.destination
                      as!GroupHistoryViewController
            dest.curGroup = selectedGroup
        }
    }
    
//    func confirmDelete(planet: String) {
//        let alert = UIAlertController(title: "Delete Group", message: "Are you sure you want to permanently delete \(planet)?", preferredStyle: .actionSheet)
//        
//        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeletePlanet)
//        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeletePlanet)
//        
//        alert.addAction(DeleteAction)
//        alert.addAction(CancelAction)
//        
//        // Support display in iPad
//        alert.popoverPresentationController?.sourceView = self.view
//        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
//        
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    func handleDeletePlanet(alertAction: UIAlertAction!) -> Void {
//        if let indexPath = deletePlanetIndexPath {
//            tableView.beginUpdates()
//            
//            planets.removeAtIndex(indexPath.row)
//            
//            // Note that indexPath is wrapped in an array:  [indexPath]
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//            
//            deletePlanetIndexPath = nil
//            
//            tableView.endUpdates()
//        }
//    }
//    
//    func cancelDeletePlanet(alertAction: UIAlertAction!) {
//        deletePlanetIndexPath = nil
//    }
}
