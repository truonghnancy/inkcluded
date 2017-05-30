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
    var delComf : Bool = false
    
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
        print("view appear")
        if (apiCalls.currentUser == nil) {
            super.viewDidAppear(animated)
            self.performSegue(withIdentifier: "showLogin" , sender: self)
            self.groups = apiCalls.groupList
        }
        
//        else if ((groups?.isEmpty)!) {
//            let loadView = LoadView(frame: self.view.frame)
//            self.view.addSubview(loadView)
//            apiCalls.getGroupsAPI(sid: apiCalls.currentUser!.id, closure: { (groupList) in
//                self.groups = groupList
//                self.groupsTableView.reloadData()
//                loadView.removeFromSuperview()
//            })
//        }
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
    
    @IBAction func unwindtoGroups(seque: UIStoryboardSegue) {
        
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
        let url = URL(string: "https://goo.gl/forms/TErdjjwKSdnjbAWx1")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
        else {
            print("feedback url could not be opened")
        }
    }
    
    // TODO: make a confirmation popup
    // need to figure out a way to refresh the groups after logging back in as a different user
    func didClickOnLogoutButton() {
        confirmLogout()
    }
    
    func didClickOnTutorialButton() {
        self.performSegue(withIdentifier: "viewTutorialSegue", sender: self)
        closeMenu()
    }
    
    func confirmLogout() {
        let alert = UIAlertController(title: "Log Out", message: "Do you want to log out as \(APICalls.sharedInstance.currentUser!.firstName)?", preferredStyle: .actionSheet)
        
        let LogoutAction = UIAlertAction(title: "Logout", style: .destructive, handler: handleLogout)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancelLogout)
        
        alert.addAction(LogoutAction)
        alert.addAction(CancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 1.0, y: 1.0, width: self.view.bounds.size.width / 2.0, height: self.view.bounds.size.height / 2.0)
        //        (self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogout(alertAction: UIAlertAction) -> Void {
        APICalls.sharedInstance.logout()
        print("logged out")
        self.groups?.removeAll()
        self.groupsTableView.reloadData()
        self.performSegue(withIdentifier: "showLogin" , sender: self)
        closeMenu()
    }
    
    func handleCancelLogout(alertAction: UIAlertAction) -> Void{
        
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
            let groupselect = groups![indexPath.row]
            print(groupselect.id)
            print(indexPath.row)
            
            confirmDelete(groupName: groupselect.groupName, tableView: tableView, indexPath: indexPath)
        }
    }
    
    func confirmDelete(groupName: String, tableView: UITableView, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Group", message: "Do you want to permanently delete \(groupName)?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteGroup(tableView: tableView, forRowAt: indexPath))
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancelGroup)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 1.0, y: 1.0, width: self.view.bounds.size.width / 2.0, height: self.view.bounds.size.height / 2.0)
//        (self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeleteGroup(tableView: UITableView, forRowAt indexPath: IndexPath) -> ((UIAlertAction) -> Void) {
        func deleteGroup(alertAction: UIAlertAction) -> Void {
            print("delete called")
            print(indexPath.row)
            let apiCalls = APICalls.sharedInstance
            apiCalls.leaveGroup(group: self.groups![indexPath.row])
            self.groups?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.deleteGroup = nil
        }
        return deleteGroup
    }

    func handleCancelGroup(alertAction: UIAlertAction) -> Void{
        deleteGroup = nil
        delComf = false
    }
    
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
        // If we're segueing to the new group view, set the groups array.
        else if (segue.identifier == "createGroupSegue") {
            let dest: RecipientsViewController = segue.destination
                as!RecipientsViewController
            dest.groupsViewController = self
        }
    }

}
