/**
 * Controls the view for selecting recipients for a new message.
 *
 * RecipientsViewController.swift
 * inkcluded-405
 *
 * Created by Christopher on 1/30/17.
 * Copyright © 2017 Boba. All rights reserved.
 */

import Foundation
import UIKit

class RecipientsViewController: UIViewController, UITableViewDelegate,
                                UITableViewDataSource {
    @IBOutlet var friendsTableView: UITableView!
    @IBOutlet var selectButton: UIBarButtonItem!
    
    var selectedRecipients = [User]()         // A list of selected recipients
    var friends : [User]?                     // A list of friends to select
    var createdGroup: Group?                  // group created from selected recipients
    
    /**
     * Performs setup once the view loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friends = Array(APICalls.sharedInstance.friendsList)
        selectButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.friends = Array(APICalls.sharedInstance.friendsList)
        self.friendsTableView.reloadData()
    }
    
    /**
     * Returns the number of cells required in the table.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends!.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    /**
     * Sets the content of one cell in the table.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.friendsTableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendTableViewCell
        let friend = self.friends?[indexPath.row];
        cell.textLabel?.text = friend!.firstName + " " + friend!.lastName
        
        let userIndex = self.selectedRecipients.index(of: friend!)
        cell.isSelected = userIndex != nil && userIndex! >= 0
        
        return cell
    }
    
    /**
     * Responds to a cell's being selected.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add the friend corresponding to the cell to the recipients list.
        let tempRecipient: User = (self.friends?[indexPath.row])!
        self.selectedRecipients.append(tempRecipient);
        
        self.selectButton.isEnabled = self.selectedRecipients.count > 0
    }
    
    /**
     * Responds to a cell's being deselected.
     */
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let tempRecipient = self.friends?[indexPath.row]
        self.selectedRecipients = self.selectedRecipients.filter { (selectedUser) -> Bool in
            return selectedUser.id != tempRecipient!.id
        }
        
        self.selectButton.isEnabled = self.selectedRecipients.count > 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newCanvasSegue" {
            let destination = segue.destination as? CanvasViewController
            destination?.msgGroup = createdGroup
        }
    }
    
    /**
     * Responds to the 'Select' button's being pressed.
     */
    @IBAction func selectPressed(_ sender: UIBarButtonItem) {
        if (self.selectedRecipients.count > 0) {
            let alertController = UIAlertController(title: "Group Name", message: "", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                let newGroupName = alertController.textFields![0].text
                
                APICalls.sharedInstance.createGroup(members: self.selectedRecipients, name: newGroupName != nil ? newGroupName! : "New Group") { (newGroup) in
                    if (newGroup == nil) {
                        let alert = UIAlertController(title: "Error", message: "Failed to Create New Group", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        return
                    }
                    
                    self.createdGroup = newGroup
                    
                    self.selectedRecipients = []
                    self.selectButton.isEnabled = false
                    self.performSegue(withIdentifier: "newCanvasSegue", sender: self)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addTextField { (textField) in
                textField.placeholder = "New Group Name"
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
        
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

