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
    
    var selectedRecipients = [User]()         // A list of selected recipients
    var friends : [User]?                     // A list of friends to select
    
    /**
     * Performs setup once the view loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friends = Array(APICalls.sharedInstance.friendsList)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.friends = Array(APICalls.sharedInstance.friendsList)
        self.friendsTableView.reloadData()
    }
    
    /**
     * Returns the number of cells required in the table.
     */
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return friends!.count;
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    /**
     * Sets the content of one cell in the table.
     */
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.friendsTableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendTableViewCell
        // Get the corresponding friend from the list.
        let friend = self.friends?[indexPath.row];
        // Set the cell's text to be the friend's name.
        cell.textLabel?.text = friend!.firstName + " " + friend!.lastName
        
        return cell
    }
    
    /**
     * Responds to a cell's being selected.
     */
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        // Add the friend corresponding to the cell to the recipients list.
        let tempRecipient: User = (self.friends?[indexPath.row])!
        self.selectedRecipients.append(tempRecipient);
    }
    
    /**
     * Responds to a cell's being deselected.
     */
    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        // Remove the friend corresponding to the cell from the recipients list.
        let tempRecipient: User = (self.friends?[indexPath.row])!
        //let tempIdx = 0//self.selectedRecipients.index(of: tempRecipient.id)
        self.selectedRecipients.remove(at: 0)
    }
    
    /**
     * Responds to the 'Select' button's being pressed.
     */
    @IBAction func selectPressed(_ sender: UIBarButtonItem) {
        // TODO: Pass this new group to the canvas view.
        APICalls.sharedInstance.createGroup(members: selectedRecipients, name: "New Group", closure: {(Group) -> Void in})
        
        self.performSegue(withIdentifier: "newCanvasSegue", sender: self)
    }
}

