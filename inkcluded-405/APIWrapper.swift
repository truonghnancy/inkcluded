//
//  APIWrapper.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/22/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation

class APIWrapper : APIProtocol {
    
    var friendsList: [User];
    var groupList: [Group];
    var messageList: [Message];
    
    init() {
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //let client = appDelegate.client
        
        self.friendsList = []
        self.groupList = []
        self.messageList = []
        
        //self.groupList = self._getGroupsAPI(client: client!, sid: String(describing: appDelegate.userEntry![AnyHashable("id")]!))
    }
    
    /*
        Gets the groups the user is a part of.
     */
    func _getGroupsAPI(client: MSClient, sid: String) -> [Group] {
        let groupTable = client.table(withName: "GroupXUser")
        let query = groupTable.query(with: NSPredicate(format: "userid = %@", sid))
        var groups: [Group] = []
        
        
        
        query.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                print(items)
                for item in items {
                    let (groupName, admin) = self._getGroupInfo(client: client, groupId: item["groupid"] as! String)
                    groups.append(Group(id: item["groupid"] as! String, members: self._getGroupMembersAPI(client: client, groupId: item["groupid"] as! String), groupName: groupName, admin: admin))
                }
            }
        }
        
        return groups
    }
    
    /*
        Gets the name and the admin of a group
        returns a tuple (name, admin)
    */
    func _getGroupInfo (client: MSClient, groupId: String) -> (String, String) {
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
    func _getGroupMembersAPI(client: MSClient, groupId: String) -> [User] {
        let gxuTable = client.table(withName: "GroupXUser")
        let QS_GXU = gxuTable.query(with: NSPredicate(format: "groupid = %@", groupId))
        var members: [User] = []
        
        QS_GXU.read { (result, error) in
            if let err = error {
                print("ERROR", err)
            } else if let items = result?.items {
                print("group members", items)
                for item in items {
                    members.append(self._getUserAPI(client: client, userId: item["userid"] as! String))
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
    func _getUserAPI(client: MSClient, userId: String) -> User {
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
        }
        
        return retUser!
    }
    
    func getFriendsList() -> [User] {
        return self.friendsList;
    }
    
    func getFriendById(userId: String) -> User {
        return self.friendsList.filter({ (user) -> Bool in
            return user.id == userId
        })[0];
    }
    
    func getCurrentUser() -> User {
        return User(id: "1345", firstName: "dr", lastName: "janzen")
    }
    
    func createGroup(members: [User], name: String, closure: @escaping ([Group]) -> Void){
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //let client = appDelegate.client
        //let groupTable = client?.table(withName: "Group")
        //let gxuTable = client?.table(withName: "GroupXUser")
        //let userEntry = appDelegate.userEntry as! [AnyHashable : String]
        //var newGroup: Group?
        //var groupId: String?
        
       // groupTable?.insert(["name" : name, "adminid" : userEntry[AnyHashable("id")]!]) { (result, error) in
       //     if error != nil {
       //         print(error!)
       //     } else {
       //         let item = result as! [AnyHashable : String]
       //         groupId = item["id"]!
       //     }
       // }
        
        //for member in members {
        //    gxuTable?.insert(["groupid" : groupId!, "userid" : member.id])
        //}
        
        
        //newGroup = Group(id: groupId!, members: members, groupName: name, admin: userEntry[AnyHashable("id")]!)
        
        //self.groupList.append(newGroup!);
        
    }
    
    func getAllGroups() -> [Group] {
        return self.groupList;
    }
    
    func findUserByEmail(email: String, closure: @escaping ([User]) -> Void)
    {
        
    }
    
//    func getGroupById(groupId: Int) -> Group {
//        return self.groupList.filter({ (group) -> Bool in
//            return group.id == groupId;
//        })[0];
//    }
    
    func getAllMessagesInGroup(groupId: String) -> [Message] {
        return self.messageList.filter({ (message) -> Bool in
            message.groupId == groupId;
        });
    }
    
//    func sendMessage(message: Message) {
//        self.messageList.append(message);
//    }
}
