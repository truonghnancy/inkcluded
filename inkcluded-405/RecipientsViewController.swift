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
                                UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var friendsSearchController: UISearchDisplayController!
    @IBOutlet var friendsTableView: UITableView!
    @IBOutlet var selectButton: UIBarButtonItem!
    
    var apiCalls: APICalls?                // The database interface
    var curUid: String?                    // The current user ID
    var selectedRecipients = [User]()      // A list of selected recipients
    var friends : [User]?                  // A list of friends to select
    var searchResults = [User]()           // A list of search results
    var doShowSearchResults : Bool = false // If the search table is visible
    var createdGroup: Group?               // A group created from recipients
    
    /**
     * Performs setup once the view loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Query the API to populate the inital friends list.
        self.apiCalls = APICalls.sharedInstance
        self.friends = Array(APICalls.sharedInstance.friendsList)
        self.curUid = apiCalls?.currentUser?.id
        selectButton.isEnabled = false
    }
    
    /**
     * Performs setup once the view appears.
     */
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
        return doShowSearchResults ? searchResults.count : friends!.count
    }
    
    /**
     * Returns the desired height of a row in the table.
     */
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    /**
     * Sets the content of one cell in the table.
     */
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the cell from the table.
        let cell = friendsTableView.dequeueReusableCell(
                    withIdentifier: "friendCell") as! FriendTableViewCell
        
        // Get the corresponding friend from the appropriate list. Make sure to
        //  check the bounds, just in case some odd searching race condition has
        //  emptied the list while we still think we need to display something.
        var tempFriend : User?
        if doShowSearchResults && indexPath.row < searchResults.count {
            tempFriend = searchResults[indexPath.row];
        }
        else if indexPath.row < (friends?.count)! {
            tempFriend = friends?[indexPath.row];
        }
        else {
            // This shouldn't ever be true, but just in case...
            return cell
        }
        
        // Set the cell's text to be the friend's name.
        cell.textLabel?.text =
         "\(tempFriend!.firstName) \(tempFriend!.lastName)"
        
        if !doShowSearchResults {
            let userIndex = self.selectedRecipients.index(of: tempFriend!)
            cell.isSelected = userIndex != nil && userIndex! >= 0
        }
        
        return cell
    }
    
    /**
     * Returns the first index of a User in an array.
     */
    func getIndexOfUser(_ userArray : [User], keyUser : User) -> Int {
        for (idx, tempUser) in userArray.enumerated() {
            if tempUser.id == keyUser.id {
                return idx
            }
        }
        return -1
    }
    
    /**
     * Responds to a cell's being selected.
     */
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 0 {
            if doShowSearchResults && indexPath.row < searchResults.count {
                // Add the user corresponding to the cell to the list of 
                //  friends if it hasn't already been added.
                let tempRecipient: User = (searchResults[indexPath.row])
                if getIndexOfUser(friends!, keyUser: tempRecipient) < 0 {
                    friends?.append(tempRecipient)
                    // Since searching is by exact match, we can just end it.
                    doShowSearchResults = false
                    self.friendsSearchController.setActive(false, animated: true)
                    friendsTableView.reloadData()
                }
            }
            else if indexPath.row < (friends?.count)! {
                // Add the friend corresponding to the cell to the recipients 
                //  list. Enable the select button.
                let tempRecipient: User = (friends?[indexPath.row])!
                selectedRecipients.append(tempRecipient)
            
                self.selectButton.isEnabled = self.selectedRecipients.count > 0
            }
            else {
                // In this case, the index was somehow invalid. Refresh data? 
                //  Can't replicate reported bugs.
                friendsTableView.reloadData()
                self.friendsSearchController.searchResultsTableView.reloadData()
            }
        }
    }
    
    /**
     * Responds to a cell's being deselected.
     */
    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        if !doShowSearchResults {
            // Remove the friend from the recipients list.
            let toRemove : User = (friends?[indexPath.row])!
            
            self.selectedRecipients = self.selectedRecipients.filter { (selectedUser) -> Bool in
                return selectedUser.id != toRemove.id
            }
            
//            let removeIdx : Int = getIndexOfUser(selectedRecipients,
//                                                 keyUser: toRemove)
//            if removeIdx >= 0 {
//                selectedRecipients.remove(at: removeIdx)
//            }
            
            self.selectButton.isEnabled = self.selectedRecipients.count > 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newCanvasSegue" {
            let destination = segue.destination as? GroupHistoryViewController
            destination?.curGroup = createdGroup
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
    
    /**
     * Responds to the search bar's being edited.
     */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        doShowSearchResults = true
        searchResults = [User]()
        friendsTableView.reloadData()
    }
    
    /**
     * Responds to the search bar's being cancelled.
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        doShowSearchResults = false
        friendsTableView.reloadData()
    }
    
    /**
     * Responds to the search button's being tapped.
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchBarTextDidEndEditing(searchBar)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Query the API to get the search results.
        apiCalls?.findUserByEmail(
         email: searchBar.text!,
         closure: { (tempFriends) in
            // Don't let users add themselves to groups.
            let filteredFriends = tempFriends!.filter { (tempUser) -> Bool in
                return tempUser.id != self.curUid
            }
            self.searchResults = filteredFriends.count > 0 ? filteredFriends : [User]()
            self.friendsSearchController.searchResultsTableView.reloadData()
         })
    }
}

