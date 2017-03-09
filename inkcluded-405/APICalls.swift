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
    private(set) var path: String?;
    private(set) var groupId: String;
    private(set) var timestamp: String;
    private(set) var sender: String;
    private(set) var username: String
    
    init(path: String, groupId: String, timestamp: String, sender: String, username: String) {
        self.path = path;
        self.groupId = groupId;
        self.timestamp = timestamp;
        self.sender = sender;
        self.username = username;
    }
}

class APICalls : APIProtocol {
    var friendsList: [User]
    var groupList: [Group]
    var messageList: [Message]
    let client: MSClient
    var currentUser : User?
    var azsBlobClient : AZSCloudBlobClient

    init() {
        client = MSClient(
            applicationURLString:"https://penmessageapp.azurewebsites.net"
        )
        
        var azsAccount : AZSCloudStorageAccount?
        
        do {
            try azsAccount = AZSCloudStorageAccount(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=penmessagestorage;AccountKey=BV5WR1Km404XR6K8F/KxOKuAyTw0utckHVZvOqW/LO5+cUTNVdZ9hShhBS/oOR7VAjKaSlt9+nBVVLXdvRpCgQ==")
        }
        catch {
            print("unable to create azure storage account")
        }
        
        azsBlobClient = (azsAccount?.getBlobClient())!
        
        self.friendsList = []
        self.groupList = []
        self.messageList = []
    }
    
    /**
     Sets the userEntry and updates the groups
     Josh Choi
     */
    func setUserEntry(result : User) {
        currentUser = result
        self._getGroupsAPI(sid: String(describing: currentUser!.id)) { (groups) in
            self.groupList = groups
        }
    }
    
    /**
     Adds the User to the database if they're not already existing
     Josh Choi
    */
    func addUserToDatabase(closure: @escaping (User?) -> Void) {
        let sid = client.currentUser?.userId
        let userTable = client.table(withName: "User")
        let query = userTable.query(with: NSPredicate(format: "id = %@", sid!))
        
        query.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
                closure(nil)
                return
            }
            else if result?.items?.count == 0 {
                userTable.insert(["id" : sid!]) { (result, error) in
                    if error != nil {
                        print(error!)
                        closure(nil)
                    }
                    else  {
                        let tempUser = User(id: result![AnyHashable("id")] as! String, firstName: result![AnyHashable("firstName")] as! String, lastName: result![AnyHashable("lastName")] as! String)
                        self.setUserEntry(result: tempUser)
                        closure(self.currentUser!)
                    }
                }
            }
            else if (result?.items) != nil {
                let tempUser = User(id: (result?.items?[0])![AnyHashable("id")] as! String, firstName: (result?.items?[0])![AnyHashable("firstName")] as! String, lastName: (result?.items?[0])![AnyHashable("lastName")] as! String)
                self.setUserEntry(result: tempUser)
                closure(self.currentUser!)
            }
        }
    }
    
    /*
     Gets the groups the user is a part of.
     Eric Roh
     */
    func _getGroupsAPI(sid: String, closure: @escaping ([Group]) -> Void){
        let groupTable = client.table(withName: "GroupXUser")
        let query = groupTable.query(with: NSPredicate(format: "userid = %@", sid))
        var groups: [Group] = []
        let myDispatchGroup = DispatchGroup()
        
        query.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
            } else if let items = result?.items {
                print(items)
                for item in items {
                    myDispatchGroup.enter()
                    self._getGroupInfo(groupId: item[AnyHashable("groupId")] as! String, closure:
                        {(groupName, adminName) -> Void in
                            self._getGroupMembersAPI(groupId: item[AnyHashable("groupId")] as! String, closure:
                                {(members) -> Void in
                                    groups.append(Group(id: item[AnyHashable("groupId")] as! String, members: members, groupName: groupName, admin: adminName))
                                    myDispatchGroup.leave()
                            })
                    })
                }
                
            }
            myDispatchGroup.notify(queue: .main, execute: {
                closure(groups)
            })
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
        let myDispatchGroup = DispatchGroup()
        
        QS_GXU.read { (result, error) in
            if let err = error {
                print("ERROR", err)
            } else if let items = result?.items {
                print("group members", items)
                for item in items {
                    myDispatchGroup.enter()
                    self._getUserAPI(userId: item[AnyHashable("userId")] as! String, closure:
                        {(user) -> Void in
                            members.append(user)
                            myDispatchGroup.leave()
                    })
                }
            }
            myDispatchGroup.notify(queue: .main, execute: {
                closure(members)
            })
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
                if items.count > 0 {
                    var user = items[0]
                    print("going through result")
                    retUser = User(id: user[AnyHashable("id")] as! String, firstName: user[AnyHashable("firstName")] as! String, lastName: user[AnyHashable("lastName")] as! String)
                    self.friendsList.append(retUser!)
                    closure(retUser!)
                }
            }
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
        myMembers.append(User(id: currentUser!.id, firstName: currentUser!.firstName, lastName: currentUser!.lastName))
        
        groupTable.insert(["name" : name, "adminId" : self.currentUser!.id]) { (result, error) in
            if error != nil {
                print(error!)
            } else {
                groupId = result?[AnyHashable("id")]! as! String?
            }
            
            for member in myMembers {
                gxuTable.insert(["groupId" : groupId!, "userId" : member.id])
            }
            
            newGroup = Group(id: groupId!, members: members, groupName: name, admin: self.currentUser!.id)
            
            self.groupList.append(newGroup!)
            closure(newGroup!)
        }
    }
    
    /**
     Sends a file to the group's container
     Josh Choi
     */
    func sendMessage(groupId: String, file: URL) {
        let blobContainer = azsBlobClient.containerReference(fromName: groupId)
        blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil, completionHandler: { (error, exists) in
            if (error != nil) {
                print("Error while creating blob container", error!, exists)
            }
            else {
                let timestamp = String(format: "%f", NSDate().timeIntervalSince1970 * 1000);
                let blockBlob = blobContainer.blockBlobReference(fromName: self.currentUser!.id + timestamp)
                
                blockBlob.metadata["timestamp"] = timestamp
                blockBlob.metadata["sender"] = self.currentUser!.id
                blockBlob.metadata["username"] = self.currentUser!.firstName
                
                blockBlob.uploadMetadata(completionHandler: {(err) in
                    if err != nil {
                        print("Error in uploading metadata", err!)
                    }
                })
                
                blockBlob.uploadFromFile(with: file, completionHandler: { (err) in
                    if err != nil {
                        print("Error in uploading blob", err!)
                    }
                })
            }
        })
    }
    
    /*
     Gets all messages of a groupid and requires a closure that takes in the name of all the blobs that were retrieved
     Josh Choi
     */
    func getAllMessage(groupId: String, closure: @escaping ([Message]) -> Void) {
        let blobContainer = azsBlobClient.containerReference(fromName: groupId)
        
        blobContainer.listBlobsSegmented(with: nil, prefix: nil, useFlatBlobListing: true, blobListingDetails: AZSBlobListingDetails.metadata, maxResults: -1, completionHandler: { (error, result) in
            
            if error != nil {
                print("Error in getting blob list", error!)
            }
            else {
                var blobNames = [Message]()
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                
                for blob in result!.blobs!
                {
                    let cblob = blob as! AZSCloudBlob
                    let blockBlob = blobContainer.blockBlobReference(fromName: cblob.blobName)
                    
                    let tempMessage = Message(path: documentsDirectory, groupId: groupId, timestamp: blockBlob.metadata.object(forKey: "id") as! String, sender: blockBlob.metadata.object(forKey: "sender") as! String, username: blockBlob.metadata.object(forKey: "username") as! String)
                    
                    blobNames.append(tempMessage)
                    
                    blockBlob.downloadToFile(withPath: documentsDirectory, append: false) { (error) in
                        if error != nil {
                            print("Error while downloading blob", error!)
                        }
                    }
                }
                blobNames.sorted(by: { $0.timestamp < $1.timestamp })
                closure(blobNames)
            }
            
        })
    }
}









