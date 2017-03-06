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
    @IBOutlet var friendsSearchController: UISearchDisplayController!
    
    var apiWrapper: APIWrapper?               // The database interface
    var selectedRecipients = [User]()         // A list of selected recipients
    var friends : [User]?                     // A list of friends to select
    var recipientSearchResults = [User]()     // A list of search results
    var allUsers : [User]?
    var doShowSearchResults : Bool = false
    
    /**
     * Performs setup once the view loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // TODO: Get the list of friends from the database.
        //apiWrapper = appDelegate.apiWrapper
        self.friends = [User(id: "-1", firstName: "Ben", lastName: "Kenobi")]
        
        // TODO: Get all the users from the database.
        self.allUsers = [User(id: "0", firstName: "Luke", lastName: "Skywalker"),
                         User(id: "1", firstName: "Han", lastName: "Solo"),
                         User(id: "2", firstName: "Leia", lastName: "Organa"),
                         User(id: "3", firstName: "Chewbacca", lastName: ""),
                         User(id: "4", firstName: "Artoo", lastName: "Detoo"),
                         User(id: "5", firstName: "See", lastName: "Threepio"),
                         User(id: "6", firstName: "Lando", lastName: "Calrissian")]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /**
     * Returns the number of cells required in the table.
     */
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if doShowSearchResults {
            return recipientSearchResults.count;
        }
        else {
            return friends!.count;
        }
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
        // Get the cell from the table.
        let cell = friendsTableView.dequeueReusableCell(
                    withIdentifier: "friendCell") as! FriendTableViewCell
        
        // Get the corresponding friend from the appropriate list. Make sure to
        //  check the index, just in case some odd searching race condition has
        //  emptied the list while we still think we need to display something.
        var tempFriend : User?
        if doShowSearchResults && indexPath.row < recipientSearchResults.count {
            tempFriend = recipientSearchResults[indexPath.row];
        }
        else if indexPath.row < (friends?.count)! {
            tempFriend = friends?[indexPath.row];
        }
        else {
            // This shouldn't ever be true, but just in case...
            tempFriend = User(id: "0", firstName: "", lastName: "")
        }
        
        // Set the cell's text to be the friend's name.
        cell.textLabel?.text =
         "\(tempFriend!.firstName) \(tempFriend!.lastName)"
        
        return cell
    }
    
    /**
     * Responds to a cell's being selected.
     */
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if doShowSearchResults {
            // Add the user corresponding to the cell to the list of friends.
            let tempRecipient: User = (recipientSearchResults[indexPath.row])
            friends?.append(tempRecipient)
            friendsTableView.reloadData()
        }
        else {
            // Add the friend corresponding to the cell to the recipients list.
            let tempRecipient: User = (self.friends?[indexPath.row])!
            self.selectedRecipients.append(tempRecipient)
        }
    }
    
    /**
     * Responds to a cell's being deselected.
     */
    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        if !doShowSearchResults {
            // Remove the friend from the recipients list.
            let tempRecipient: User = (self.friends?[indexPath.row])!
            //let tempIdx = 0//self.selectedRecipients.index(of: tempRecipient.id)
            self.selectedRecipients.remove(at: 0)
        }
    }
    
    /**
     * Responds to the 'Select' button's being pressed.
     */
    @IBAction func selectPressed(_ sender: UIBarButtonItem) {
        // If no recipients have been selected, do nothing.
        //if selectedRecipients.isEmpty {
        //    print("No recipients selected.")
        //}
        // Otherwise, create a new group using the selected recipients.
        //else {
        var members = [User]()
        
        print("Recipients:")
        for recipientIdx : User in selectedRecipients {
            let recipient = apiWrapper?.getFriendById(userId: recipientIdx.id)
            print("   \(recipient?.firstName) \(recipient?.lastName)")
        }
        // TODO: Pass this new group to the canvas view.
        apiWrapper?.createGroup(members: selectedRecipients, name: "New Group", closure: {(Group) -> Void in})
        
        // Segue to the canvas view.
        self.performSegue(withIdentifier: "newCanvasSegue", sender: self)
        //}
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
        filterSearchResults(searchBar.text!)
        friendsSearchController.searchResultsTableView.reloadData()
    }
    
    /**
     * Filters search results into an array.
     */
    func filterSearchResults(_ queryRaw : String) {
        let queryLower = queryRaw.lowercased()
        
        // Clear any old search results and re-iterate over all users.
        self.recipientSearchResults = []
        for tempUser : User in self.allUsers! {
            // TODO: Search by email, not by first name.
            if tempUser.firstName.lowercased().range(of: queryLower) != nil {
                self.recipientSearchResults.append(tempUser)
            }
        }
    }
}

