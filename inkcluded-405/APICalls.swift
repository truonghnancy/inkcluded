//
//  APICalls.swift
//  inkcluded-405
//
//  Created by Min Woo Roh on 2/19/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import AZSClient

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
    //var azsAccount : AZSCloudStorageAccount?
    var azsBlobClient : AZSCloudBlobClient

    init() {
        client = MSClient(
            applicationURLString:"https://penmessageapp.azurewebsites.net"
        )
        
        var azsAccount : AZSCloudStorageAccount?
        
        do {
            try azsAccount = AZSCloudStorageAccount(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=penmessagestorage;AccountKey=yms7hVcWTLxZbuZP9TE9UldDAGrcd2aKmw9qXLJQTLTR8j7njOpc8+KY8EpoabfaDw/5JeROwcOJtWJtVU0E1A")
        }
        catch {
            print("unable to create azure storage account")
        }
        
        azsBlobClient = (azsAccount?.getBlobClient())!
        
        self.friendsList = []
        self.groupList = []
        self.messageList = []
        
        //findUserByEmail(email: "rohroh94@gmail.com") { (user) in}
    }
    
    /**
     Sets the userEntry and updates the groups
     Josh Choi
     */
    func setUserEntry(result : [AnyHashable : Any]) {
        userEntry = result
        self._getGroupsAPI(sid: String(describing: userEntry![AnyHashable("id")]!))
    }
    
    /**
     Adds the User to the database if they're not already existing
     Josh Choi
    */
    func addUserToDatabase(closure: @escaping ([AnyHashable : Any]) -> Void) {
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
            closure(self.userEntry!)
        }
    }
    
    /*
     Gets the groups the user is a part of.
     Eric Roh
     */
    func _getGroupsAPI(sid: String) {
        let groupTable = client.table(withName: "GroupXUser")
        let query = groupTable.query(with: NSPredicate(format: "userid = %@", sid))
        var groups: [Group] = []
        
        query.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                print(items)
                for item in items {
                    self._getGroupInfo(groupId: item[AnyHashable("groupId")] as! String, closure:
                        {(groupName, adminName) -> Void in
                            self._getGroupMembersAPI(groupId: item[AnyHashable("groupId")] as! String, closure:
                                {(members) -> Void in
                                    groups.append(Group(id: item[AnyHashable("groupId")] as! String, members: members, groupName: groupName, admin: adminName))
                            })
                    })
                }
            }
            self.groupList = groups
        }
    }
    
    /*
     Gets the name and the admin of a group
     returns a tuple (name, admin)
     Eric Roh
     */
    func _getGroupInfo (groupId: String, closure: @escaping ((String, String)) -> Void) {
        let groupTable = client.table(withName: "Group")
        let query = groupTable.query(with: NSPredicate(format: "id = %@", groupId))
        var groupInfo: (String, String)?
        
        query.read { (result, error) in
            if let err = error {
                print("Selecting group info failed: ", err)
            } else if let item = result?.items?[0] {
                groupInfo = (item[AnyHashable("name")] as! String, item[AnyHashable("adminId")] as! String)
            }
            closure(groupInfo!)
        }
    }
    
    /*
     Gets the member(s) of the group.
     Eric Roh
     */
    func _getGroupMembersAPI(groupId: String, closure: @escaping ([User]) -> Void) {
        let gxuTable = client.table(withName: "GroupXUser")
        let QS_GXU = gxuTable.query(with: NSPredicate(format: "groupid = %@", groupId))
        var members: [User] = []
        
        QS_GXU.read { (result, error) in
            if let err = error {
                print("ERROR", err)
            } else if let items = result?.items {
                print("group members", items)
                for item in items {
                    self._getUserAPI(userId: item[AnyHashable("userId")] as! String, closure:
                        {(user) -> Void in
                            members.append(user)
                    })
                }
            }
            closure(members)
        }

    }
    
    /**
     Gets the user from the Azure easy tables with the userId
     returns : User
     Eric Roh
     */
    func _getUserAPI(userId: String, closure: @escaping (User) -> Void) {
        let cTable = client.table(withName: "User")
        let QS_USER = cTable.query(with: NSPredicate(format: "id = %@", userId))
        var retUser: User?
        
        QS_USER.read { (result, error) in
            if let err = error {
                print("ERROR", err)
            } else if let items = result?.items {
                print("USER IS ", items[0])
                let user = items[0]
                retUser = User(id: user[AnyHashable("id")] as! String, firstName: user[AnyHashable("firstName")] as! String, lastName: user[AnyHashable("lastName")] as! String)
            }
            closure(retUser!)
            print(retUser!)
        }
    }
    /**
    Finds user with a email in the database tables.
     Eric Roh
     */
    func findUserByEmail(email: String, closure: @escaping (User) -> Void) {
        let userTable = client.table(withName: "User")
        let userEmail = userTable.query(with: NSPredicate(format: "email = %@", email))
        var retUser: User?

        print(userTable)
        userEmail.read { (result, error) in
            if let err = error {
                print("Error in Finding User by Email: ", err)
            } else if let items = result?.items {
                let user = items[0]
                print("hello")
                retUser = User(id: user[AnyHashable("id")] as! String, firstName: user[AnyHashable("firstName")] as! String, lastName: user[AnyHashable("lastName")] as! String)
            }
            self.friendsList.append(retUser!)
            closure(retUser!)
        }
    }
    
    /**
     Adds a new group to the database with given members and current user.
     Eric Roh
    */
    func createGroup(members: [User], name: String, closure: @escaping (Group) -> Void) {
        let groupTable = client.table(withName: "Group")
        let gxuTable = client.table(withName: "GroupXUser")
        var newGroup: Group?
        var groupId: String?
        var myMembers = members
        myMembers.append(User(id: userEntry?[AnyHashable("id")] as! String, firstName: userEntry?[AnyHashable("firstName")] as! String, lastName: userEntry?[AnyHashable("lastName")] as! String))
        
        groupTable.insert(["name" : name, "adminId" : self.userEntry?[AnyHashable("id")] as! String]) { (result, error) in
            if error != nil {
                print(error!)
            } else {
                groupId = result?[AnyHashable("id")]! as! String?
            }
            
            for member in myMembers {
                gxuTable.insert(["groupId" : groupId!, "userId" : member.id])
            }
            
            newGroup = Group(id: groupId!, members: members, groupName: name, admin: self.userEntry?[AnyHashable("id")] as! String)
            
            self.groupList.append(newGroup!)
            closure(newGroup!)
        }
    }
    
    /**
     Sends a file to the group's container
     */
    func sendMessage(groupId: String, file: URL) {
        let blobContainer = azsBlobClient.containerReference(fromName: groupId)
        
        blobContainer.createContainerIfNotExists(completionHandler: { (error, exists) in
            if error != nil {
                print("Error while creating blob container", error!)
            }
            else {
                let blockBlob = blobContainer.blockBlobReference(fromName: self.userEntry?[AnyHashable("id")] as! String)
                
                blockBlob.uploadFromFile(with: file, completionHandler: { (err) in
                    if err != nil {
                        print("Error in uploading blob", err!)
                    }
                })
            }
        })
    }
    
    /*
     Gets all messages of a groupid
     */
    func getAllMessage(groupId: String) {
        let blobContainer = azsBlobClient.containerReference(fromName: groupId)
        
        blobContainer.listBlobsSegmented(with: nil, prefix: nil, useFlatBlobListing: true, blobListingDetails: AZSBlobListingDetails.all, maxResults: -1, completionHandler: { (error, result) in
            
            if error != nil {
                print("Error in getting blob list", error!)
            }
            else {
                
                for blob in result!.blobs!
                {
                    let cblob = blob as! AZSCloudBlob
                    let blockBlob = blobContainer.blockBlobReference(fromName: cblob.blobName)
                    blockBlob.downloadToFile(withPath: "", append: false) { (error) in
                        if error != nil {
                            print("Error while downloading blob", error!)
                        }
                    }
                }
            }
            
        })
    }
}









