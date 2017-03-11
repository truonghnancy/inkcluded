//
//  APICalls.swift
//  inkcluded-405
//
//  Created by Min Woo Roh on 2/19/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import AZSClient

struct User: Hashable {
    private(set) var id: String;
    private(set) var firstName: String;
    private(set) var lastName: String;
    
    init(id: String, firstName: String, lastName: String) {
        self.id = id;
        self.firstName = firstName;
        self.lastName = lastName;
    }
    
    var hashValue: Int {
        // DJB hash function
        return id.hash
    }
    
    static func ==(left: User, right: User) -> Bool {
        return left.id == right.id
    }
}

struct Group {
    private(set) var id: String;
    private(set) var members: [User];
    private(set) var groupName: String;
    private(set) var admin: String;
    private(set) var messages: [Message];
    
    init(id: String, members: [User], groupName: String, admin: String, messages: [Message]) {
        self.id = id;
        self.members = members;
        self.groupName = groupName;
        self.admin = admin;
        self.messages = messages;
    }
}

struct Message {
    private(set) var filepath: String;
    private(set) var filename: String;
    private(set) var groupid: String;
    private(set) var timestamp: String;
    private(set) var senderid: String;
    private(set) var senderfirstname: String;
    
    init(filepath: String, filename: String, groupid: String, timestamp: String, senderid: String, senderfirstname: String) {
        self.filepath = filepath;
        self.filename = filename;
        self.groupid = groupid;
        self.timestamp = timestamp;
        self.senderid = senderid;
        self.senderfirstname = senderfirstname;
    }
}

class APICalls {
    var friendsList: Set<User>
    var groupList: [Group]
    let client: MSClient
    var currentUser : User?
    var azsBlobClient : AZSCloudBlobClient
    
    static let sharedInstance = APICalls()
    
    private init() {
        client = MSClient(
            applicationURLString:"https://penmessageapp.azurewebsites.net"
        )
        
        var azsAccount : AZSCloudStorageAccount?
        
        //findUserByEmail(email: "rohroh94@gmail.com") { (user) in
            
        //}
    }
    
    func login(closure: @escaping (User?) -> Void) {
        let sid = client.currentUser?.userId
        let userTable = client.table(withName: "User")
        
        _getUserAPI(userId: sid!, closure: { (user) in
            if (user == nil) {
                userTable.insert(["id" : sid!]) { (result, error) in
                    if error != nil {
                        print(error!)
                        closure(nil)
                        return
                    }
                    else  {
                        let tempUser = User(id: result![AnyHashable("id")] as! String, firstName: result![AnyHashable("firstName")] as! String, lastName: result![AnyHashable("lastName")] as! String)
                        self.currentUser = tempUser
                        closure(self.currentUser!)
                        return
                    }
                }
            }
            else {
                self.currentUser = user!
                closure(self.currentUser!)
                return
            }
        })
    }
    
    /*
     Gets the groups the user is a part of.
     Eric Roh
     */
    func getGroupsAPI(sid: String, closure: @escaping ([Group]?) -> Void){
        let groupTable = client.table(withName: "GroupXUser")
        let query = groupTable.query(with: NSPredicate(format: "userId = %@", sid))
        var groups: [Group] = []
        let myDispatchGroup = DispatchGroup()
        
        query.read { (result, error) in
            if let err = error {
                print("ERROR ", err)
                closure(nil)
                return
            } else if let items = result?.items {
                for item in items {
                    myDispatchGroup.enter()
                    self._getGroupInfo(groupId: item[AnyHashable("groupId")] as! String, closure:
                        {(group) -> Void in
                            self._getGroupMembersAPI(groupId: item[AnyHashable("groupId")] as! String, closure:
                                {(members) -> Void in
                                    groups.append(Group(id: item[AnyHashable("groupId")] as! String, members: members!, groupName: (group?.0)!, admin: (group?.1)!, messages: [Message]()))
                                    for member in members! {
                                        if (member != self.currentUser!) {
                                            self.friendsList.insert(member)
                                        }
                                    }
                                    myDispatchGroup.leave()
                            })
                    })
                }
                
            }
            myDispatchGroup.notify(queue: .main, execute: {
                closure(groups)
                return
            })
        }
    }
    
    /*
     Gets the name and the admin of a group
     returns a tuple (name, admin)
     Eric Roh
     */
    private func _getGroupInfo (groupId: String, closure: @escaping ((String, String)?) -> Void) {
        let groupTable = client.table(withName: "Group")
        let query = groupTable.query(with: NSPredicate(format: "id = %@", groupId))
        var groupInfo: (String, String)?
        
        query.read { (result, error) in
            if let err = error {
                print("Selecting group info failed: ", err)
                closure(nil)
                return
            } else if let item = result?.items?[0] {
                groupInfo = (item[AnyHashable("name")] as! String, item[AnyHashable("adminId")] as! String)
                closure(groupInfo)
                return
            }
        }
    }
    
    /*
     Gets the member(s) of the group.
     Eric Roh
     */
    private func _getGroupMembersAPI(groupId: String, closure: @escaping ([User]?) -> Void) {
        let gxuTable = client.table(withName: "GroupXUser")
        let QS_GXU = gxuTable.query(with: NSPredicate(format: "groupId = %@", groupId))
        var members: [User] = []
        let myDispatchGroup = DispatchGroup()
        
        QS_GXU.read { (result, error) in
            if let err = error {
                print("ERROR", err)
                closure(nil)
                return
            } else if let items = result?.items {
                for item in items {
                    myDispatchGroup.enter()
                    self._getUserAPI(userId: item[AnyHashable("userId")] as! String, closure:
                        {(user) -> Void in
                            members.append(user!)
                            myDispatchGroup.leave()
                    })
                }
            }
            myDispatchGroup.notify(queue: .main, execute: {
                closure(members)
                return
            })
        }
        
    }
    
    /**
     Gets the user from the Azure easy tables with the userId
     returns : User
     Eric Roh
     */
    private func _getUserAPI(userId: String, closure: @escaping (User?) -> Void) {
        let cTable = client.table(withName: "User")
        let QS_USER = cTable.query(with: NSPredicate(format: "id = %@", userId))
        var retUser: User?
        
        QS_USER.read { (result, error) in
            if let err = error {
                print("ERROR", err)
                closure(nil)
                return
            }
            else if let items = result?.items {
                let user = items[0]
                retUser = User(id: user[AnyHashable("id")] as! String, firstName: user[AnyHashable("firstName")] as! String, lastName: user[AnyHashable("lastName")] as! String)
                closure(retUser)
                return
            }
            else {
                closure(nil)
                return
            }
        }
    }
    /**
     Finds user with a email in the database tables.
     Eric Roh
     */
    func findUserByEmail(email: String, closure: @escaping ([User]?) -> Void) {
        let userTable = client.table(withName: "User")
        let userEmail = userTable.query(with: NSPredicate(format: "email = %@", email))
        var retUsers = [User]()
        
        userEmail.read { (result, error) in
            if let err = error {
                print("Error in Finding User by Email: ", err)
                closure(nil)
                return
            } else if let items = result?.items {
                for item in items{
                    let tempUser = User(id: item[AnyHashable("id")] as! String, firstName: item[AnyHashable("firstName")] as! String, lastName: item[AnyHashable("lastName")] as! String)
                    retUsers.append(tempUser)
                }
                closure(retUsers)
                return
            }
        }
    }
    
    /**
     Adds a new group to the database with given members and current user.
     Eric Roh
     */
    func createGroup(members: [User], name: String, closure: @escaping (Group?) -> Void) {
        let groupTable = client.table(withName: "Group")
        let gxuTable = client.table(withName: "GroupXUser")
        var newGroup: Group?
        var groupId: String?
        let myMembers = Set(members.map { $0 })
        
        groupTable.insert(["name" : name, "adminId" : self.currentUser!.id]) { (result, error) in
            if error != nil {
                print(error!)
                closure(nil)
                return
            } else {
                groupId = result?[AnyHashable("id")]! as! String?
            }
            
            for member in myMembers {
                self.friendsList.insert(member)
                gxuTable.insert(["groupId" : groupId!, "userId" : member.id]) { (result, error) in
                    if error != nil {
                        print("Error while inserting member to GroupXUser", error!)
                        closure(nil)
                        return
                    }
                }
            }
            
            gxuTable.insert(["groupId" : groupId!, "userId" : self.currentUser!.id]) { (result, error) in
                if error != nil {
                    print("Error while inserting member to GroupXUser", error!)
                    closure(nil)
                    return
                }
            }
            
            newGroup = Group(id: groupId!, members: members, groupName: name, admin: self.currentUser!.id, messages: [Message]())
            
            self.groupList.append(newGroup!)
            closure(newGroup!)
        }
    }
    
    /**
     Sends a file to the group's container
     Josh Choi
     */
    func sendMessage(message: Message, closure: @escaping (Bool) -> Void) {
        let blobContainer = azsBlobClient.containerReference(fromName: message.groupid)
        blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil, completionHandler: { (error, exists) in
            if (error != nil) {
                print("Error while creating blob container", error!, exists)
                closure(false)
                return
            }
            else {
                let blockBlob = blobContainer.blockBlobReference(fromName: self.currentUser!.id + message.timestamp)
                
                blockBlob.metadata["timestamp"] = message.timestamp
                blockBlob.metadata["sender"] = message.senderid
                blockBlob.metadata["username"] = message.senderfirstname
                
                blockBlob.uploadFromFile(withPath: message.filepath, completionHandler: { (err) in
                    if err != nil {
                        print("Error in uploading blob", err!)
                        closure(false)
                        return
                    }
                    else {
                        closure(true)
                        return
                    }
                })
            }
        })
    }
    
    /*
     Gets all messages of a groupid and requires a closure that takes in the name of all the blobs that were retrieved
     Josh Choi
     */
    func getAllMessage(groupId: String, closure: @escaping ([Message]?) -> Void) {
        let blobContainer = azsBlobClient.containerReference(fromName: groupId)
        let myDispatchGroup = DispatchGroup()
        
        blobContainer.listBlobsSegmented(with: nil, prefix: nil, useFlatBlobListing: true, blobListingDetails: AZSBlobListingDetails.metadata, maxResults: -1, completionHandler: { (error, result) in
            
            if error != nil {
                print("Error in getting blob list", error!)
                closure(nil)
                return
            }
            else {
                var blobNames = [Message]()
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                
                for blob in result!.blobs!
                {
                    myDispatchGroup.enter()
                    
                    let cblob = blob as! AZSCloudBlob
                    let blockBlob = blobContainer.blockBlobReference(fromName: cblob.blobName)
                    
                    blockBlob.downloadAttributes(completionHandler: { (error) in
                        if (error != nil) {
                            let tempMessage = Message(filepath: "", filename: "cblob.blobName", groupid: groupId, timestamp: "", senderid: "", senderfirstname: "")
                            
                            blobNames.append(tempMessage)
                            
                            myDispatchGroup.leave()
                        }
                        else {
                            let filepath = (documentsDirectory + "/" + cblob.blobName)
                            
                            blockBlob.downloadToFile(withPath: filepath, append: false) {
                                (error) in
                                if error != nil {
                                    
                                    let tempMessage = Message(
                                        filepath: "",
                                        filename: cblob.blobName,
                                        groupid: groupId,
                                        timestamp: blockBlob.metadata.object(forKey: "timestamp") as! String,
                                        senderid: blockBlob.metadata.object(forKey: "sender") as! String,
                                        senderfirstname: blockBlob.metadata.object(forKey: "username") as! String
                                    )
                                    
                                    blobNames.append(tempMessage)
                                    
                                    myDispatchGroup.leave()
                                }
                                else {
                                    
                                    let tempMessage = Message(
                                        filepath: filepath,
                                        filename: cblob.blobName,
                                        groupid: groupId,
                                        timestamp: blockBlob.metadata.object(forKey: "timestamp") as! String,
                                        senderid: blockBlob.metadata.object(forKey: "sender") as! String,
                                        senderfirstname: blockBlob.metadata.object(forKey: "username") as! String
                                    )
                                    
                                    blobNames.append(tempMessage)
                                    
                                    myDispatchGroup.leave()
                                }
                            }
                        }
                    })
                }
                myDispatchGroup.notify(queue: .main, execute: {
                    closure(blobNames.sorted(by: { $0.timestamp < $1.timestamp }))
                    return
                })
            }
        })
    }
}
