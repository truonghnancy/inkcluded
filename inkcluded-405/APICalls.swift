//
//  APICalls.swift
//  inkcluded-405
//
//  Created by Min Woo Roh on 2/19/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation

class APICalls : APIProtocol {
    var friendsList: [User]
    var groupList: [Group]
    var messageList: [Message]
    let _client: MSClient

    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        _client = appDelegate.client!
        
        self.friendsList = []
        self.groupList = []
        self.messageList = []
        
        if appDelegate.userEntry != nil {
            self.groupList = self._getGroupsAPI(sid: String(describing: appDelegate.userEntry![AnyHashable("id")]!))
            print("this is called")
//            _getUserAPI(userId: "sid:763ebe8184b48d3c85eafe632f56f3cb")
//            findUserByEmail(email: "rohroh94@gmail.com")
        }
        
    }
    
    /*
     Gets the groups the user is a part of.
     */
    func _getGroupsAPI(sid: String) -> [Group] {
        let groupTable = _client.table(withName: "GroupXUser")
        let query = groupTable.query(with: NSPredicate(format: "userid = %@", sid))
        var groups: [Group] = []
        
        
        
        query.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                print(items)
                for item in items {
                    let (groupName, admin) = self._getGroupInfo(groupId: item["groupid"] as! String)
                    groups.append(Group(id: item["groupid"] as! String, members: self._getGroupMembersAPI(groupId: item["groupid"] as! String), groupName: groupName, admin: admin))
                }
            }
        }
        
        return groups
    }
    
    /*
     Gets the name and the admin of a group
     returns a tuple (name, admin)
     */
    func _getGroupInfo (groupId: String) -> (String, String) {
        let groupTable = _client.table(withName: "Group")
        let query = groupTable.query(with: NSPredicate(format: "id = %@", groupId))
        var groupInfo: (String, String)?
        
        query.read { (result, error) in
            if let err = error {
                print("Selecting group info failed: ", err)
            } else if let item = result?.items?[0] {
                groupInfo = (item["name"] as! String, item["adminid"] as! String)
            }
        }
        
        return groupInfo!
    }
    
    /*
     Gets the member(s) of the group.
     */
    func _getGroupMembersAPI(groupId: String) -> [User] {
        let gxuTable = _client.table(withName: "GroupXUser")
        let QS_GXU = gxuTable.query(with: NSPredicate(format: "groupid = %@", groupId))
        var members: [User] = []
        
        QS_GXU.read { (result, error) in
            if let err = error {
                print("ERROR", err)
            } else if let items = result?.items {
                print("group members", items)
                for item in items {
                    members.append(self._getUserAPI(userId: item["userid"] as! String))
                }
            }
        }
        print("members", members)
        return members
    }
    
    /**
     Gets the user from the Azure easy tables with the userId
     returns : User
     */
    func _getUserAPI(userId: String) -> User {
        let cTable = _client.table(withName: "User")
        let QS_USER = cTable.query(with: NSPredicate(format: "id = %@", userId))
        var retUser: User?
        
        QS_USER.read { (result, error) in
            if let err = error {
                print("ERROR", err)
            } else if let items = result?.items {
                print("USER IS ", items[0])
                let user = items[0]
                retUser = User(id: user["id"] as! String, firstName: user["firstname"] as! String, lastName: user["lastname"] as! String)
            }
            print(retUser)
        }
        
        return retUser!
    }
    
    func findUserByEmail(email: String) -> User {
        let userTable = _client.table(withName: "User")
        let userEmail = userTable.query(with: NSPredicate(format: "email = %@", email))
        var retUser: User?
        //let sema = DispatchSemaphore(value: 0)
        print("here???")
        userEmail.read { (result, error) in
            print("is it even here")
            if let err = error {
                print("Error in Finding User by Email: ", err)
            } else if let items = result?.items {
                print("USER IS ", items[0])
                let user = items[0]
                retUser = User(id: user["id"] as! String, firstName: user["firstname"] as! String, lastName: user["lastname"] as! String)
            }
            print("?????", retUser!)
            //sema.signal()
        }
        sleep(4)
        //sema.wait(timeout: .distantFuture)
        return retUser!
    }

    func getFriendsList() -> [User] {
        return self.friendsList;
    }
    
    func createGroup(members: [User], name: String) -> Group {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let groupTable = _client.table(withName: "Group")
        let gxuTable = _client.table(withName: "GroupXUser")
        let userEntry = appDelegate.userEntry as! [AnyHashable : String]
        var newGroup: Group?
        var groupId: String?
        
        groupTable.insert(["name" : name, "adminid" : userEntry[AnyHashable("id")]!]) { (result, error) in
            if error != nil {
                print(error!)
            } else {
                let item = result as! [AnyHashable : String]
                groupId = item["id"]!
            }
        }
        
        for member in members {
            gxuTable.insert(["groupid" : groupId!, "userid" : member.id])
        }
        
        
        newGroup = Group(id: groupId!, members: members, groupName: name, admin: userEntry[AnyHashable("id")]!)
        
        self.groupList.append(newGroup!);
        
        return newGroup!
        
        
    }
    
    
    func getAllGroups() -> [Group] {
        return self.groupList;
    }
}
