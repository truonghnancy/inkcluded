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
    @IBOutlet var friendsTableView: UITableView!
    @IBOutlet var selectButton: UIBarButtonItem!
    
    var apiCalls: APICalls?                // The database interface
    var selectedRecipients = [User]()      // A list of selected recipients
    var friends : [User]?                  // A list of friends to select
    var searchResults = [User]()           // A list of search results
    var doShowSearchResults : Bool = false // If the search table is visible
    
    /**
     * Performs setup once the view loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the reference to our Azure API.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        apiCalls = appDelegate.apiWrapper
        // Query the API to populate the inital friends list.
        friends = apiCalls?.friendsList
    }
    
    /**
     * Performs setup once the view appears.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        let userIndex = self.selectedRecipients.index(of: friend!)
        cell.isSelected = userIndex != nil && userIndex! >= 0
        
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
        if doShowSearchResults {
            // Add the user corresponding to the cell to the list of friends, 
            //  if it hasn't already been added.
            let tempRecipient: User = (searchResults[indexPath.row])
            if getIndexOfUser(friends!, keyUser: tempRecipient) < 0 {
                friends?.append(tempRecipient)
                friendsTableView.reloadData()
            }
        }
        else {
            // Add the friend corresponding to the cell to the recipients list.
            let tempRecipient: User = (friends?[indexPath.row])!
            selectedRecipients.append(tempRecipient)
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
            let removeIdx : Int = getIndexOfUser(selectedRecipients,
                                                 keyUser: toRemove)
            if removeIdx >= 0 {
                selectedRecipients.remove(at: removeIdx)
            }
        }
    }
    
    /**
     * Responds to the 'Select' button's being pressed.
     */
    @IBAction func selectPressed(_ sender: UIBarButtonItem) {
        // If no recipients have been selected, do nothing.
        if selectedRecipients.isEmpty {
            print("No recipients selected.")
        }
        // Otherwise, create a new group using the selected recipients.
        else {
            print("Recipients:")
            for recipient : User in selectedRecipients {
                print("   \(recipient.firstName) \(recipient.lastName)")
            }
            
            // TODO: Uncomment this when we're ready to pass new groups to the
            //       DB for real. (Commented out because Christopher may have
            //       once broken stuff by passing a user with a dummy UID...
            //apiCalls?.createGroup(members: selectedRecipients, 
            //                      name: "New Group",
            //                      closure: {(Group) -> Void in})
        
            // Segue to the canvas view.
            self.performSegue(withIdentifier: "newCanvasSegue", sender: self)
        }
    }
    
    /**
     * Responds to the search bar's being edited.
     */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        doShowSearchResults = true
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
        searchBarTextDidEndEditing(searchBar)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Query the API to get the search results.
        apiCalls?.findUserByEmail(
         email: searchBar.text!,
         closure: { (tempFriends) in
             self.searchResults = tempFriends
         })
        
        // Reload the search results table.
        friendsTableView.reloadData()
    }
}

