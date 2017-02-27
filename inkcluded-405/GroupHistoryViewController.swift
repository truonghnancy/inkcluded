//
//  GroupHistoryViewController.swift
//  inkcluded-405
//
//  Created by Christopher on 2/20/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class GroupHistoryViewController: UIViewController, UITableViewDelegate,
                                  UITableViewDataSource {
    @IBOutlet weak var groupTitle: UINavigationItem!
    @IBOutlet var messageTableView: UITableView!
    
    let apiWrapper: APIWrapper = APIWrapper() // The database interface
    var curGroup: Group?                      // The displayed group
    var curMessages: [Message]?               // The displayed messages
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the group title and messages from the database.
        groupTitle.title = curGroup?.groupName
        curMessages = apiWrapper.getAllMessagesInGroup(groupId: (curGroup?.id)!)
        //curMessages?.reverse()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /**
     * Returns the number of cells required in the table.
     */
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return curMessages!.count;
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
        let cell = self.messageTableView.dequeueReusableCell(
            withIdentifier: "messageCell") as! MessageTableViewCell
        // Get the corresponding message from the list.
        let message = self.curMessages?[indexPath.row];
        // LLVM complains that this line is too complex a line if I try to do it
        //  all at once; get the sender first.
        let sender = apiWrapper.getFriendById(userId: (message?.sentFrom)!)
        // TODO: This is placeholder-ish data until our DB feeds us WILL files.
        cell.textLabel?.text = "Sent by " + sender.firstName + " on "
                               + (message?.timestamp.description)!
        
        return cell
    }
    
    /**
     * Responds to a cell's being selected.
     */
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        // TODO: This should launch a closer view of the message.
    }

}
