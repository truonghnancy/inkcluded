//
//  APICalls.swift
//  inkcluded-405
//
//  Created by Min Woo Roh on 2/19/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import RxSwift

struct User {
    private(set) var id: String;
    private(set) var firstName: String;
    private(set) var lastName: String;
    
    init(id: String, firstName: String, lastName: String) {
        self.id = id;
        self.firstName = firstName;
        self.lastName = lastName;
    }
}

struct Group {
    private(set) var id: String;
    private(set) var members: [User];
    private(set) var groupName: String;
    private(set) var admin: String;
    
    init(id: String, members: [User], groupName: String, admin: String) {
        self.id = id;
        self.members = members;
        self.groupName = groupName;
        self.admin = admin;
    }
}

struct Message {
    private(set) var id: Int;
    private(set) var url: NSURL;
    private(set) var groupId: String;
    private(set) var sentFrom: String;
    private(set) var timestamp: NSDate;
    
    init(id: Int, url: NSURL, groupId: String, sentFrom userId: String, timestamp: NSDate) {
        self.id = id;
        self.url = url;
        self.groupId = groupId;
        self.sentFrom = userId;
        self.timestamp = timestamp;
    }
}

class APICalls : APIProtocol {
    var friendsList: [User]
    var groupList: [Group]
    var messageList: [Message]
    let client: MSClient
    var userEntry : [AnyHashable : Any]?

    init() {
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        client = MSClient(
            applicationURLString:"https://penmessageapp.azurewebsites.net"
        )
        
        self.friendsList = []
        self.groupList = []
        self.messageList = []
    }
    
    func setUserEntry(result : [AnyHashable : Any]) {
        userEntry = result
        self.groupList = self._getGroupsAPI(sid: String(describing: userEntry![AnyHashable("id")]!))
        print("this is called")
        //_getUserAPI(userId: "sid:763ebe8184b48d3c85eafe632f56f3cb")
        //findUserByEmail(email: "rohroh94@gmail.com")
    }
    
    func addUserToDatabase(vccontroller : UIViewController) {
        let sid = client.currentUser?.userId
        let userTable = client.table(withName: "User")
        let query = userTable.query(with: NSPredicate(format: "id = %@", sid!))
        
        query.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if result?.items?.count == 0 {
                userTable.insert(["id" : sid!]) { (result, error) in
                    if error != nil {
                        print(error!)
                    } else  {
                        self.setUserEntry(result: result!)
                    }
                }
            } else if (result?.items) != nil {
                self.setUserEntry(result: (result?.items?[0])!)
            }
            vccontroller.dismiss(animated: true, completion: nil)
        }
    }
    
    /*
     Gets the groups the user is a part of.
     */
    func _getGroupsAPI(sid: String) -> [Group] {
        let groupTable = client.table(withName: "GroupXUser")
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
        let groupTable = client.table(withName: "Group")
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
        let gxuTable = client.table(withName: "GroupXUser")
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
        let cTable = client.table(withName: "User")
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
            print(retUser!)
        }
        
        return retUser!
    }
    
    func findUserByEmail(email: String) -> User {
        let userTable = client.table(withName: "User")
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
        let groupTable = client.table(withName: "Group")
        let gxuTable = client.table(withName: "GroupXUser")
        //let userEntry = appDelegate.userEntry as! [AnyHashable : String]
        var newGroup: Group?
        var groupId: String?
        
        groupTable.insert(["name" : name, "adminid" : userEntry?[AnyHashable("id")] as Any]) { (result, error) in
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
        
        
        newGroup = Group(id: groupId!, members: members, groupName: name, admin: userEntry?[AnyHashable("id")] as! String)
        
        self.groupList.append(newGroup!);
        
        return newGroup!
        
        
    }
    
    
    func getAllGroups() -> [Group] {
        return self.groupList;
    }
}
