//
//  APIWrapper.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/22/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation

struct User {
    private(set) var id: Int;
    private(set) var firstName: String;
    private(set) var lastName: String;
    
    init(id: Int, firstName: String, lastName: String) {
        self.id = id;
        self.firstName = firstName;
        self.lastName = lastName;
    }
}

struct Group {
    private(set) var id: Int;
    private(set) var members: [Int];
    private(set) var groupName: String;
    private(set) var admin: Int;
    
    init(id: Int, members: [Int], groupName: String, admin: Int) {
        self.id = id;
        self.members = members;
        self.groupName = groupName;
        self.admin = admin;
    }
}

struct Message {
    private(set) var id: Int;
    private(set) var url: NSURL;
    private(set) var groupId: Int;
    private(set) var sentFrom: Int;
    private(set) var timestamp: NSDate;
    
    init(id: Int, url: NSURL, groupId: Int, sentFrom userId: Int, timestamp: NSDate) {
        self.id = id;
        self.url = url;
        self.groupId = groupId;
        self.sentFrom = userId;
        self.timestamp = timestamp;
    }
}

class APIWrapper : APIProtocol {
    let user1 = User(id: 1, firstName: "francis", lastName: "yuen");
    let user2 = User(id: 2, firstName: "josh", lastName: "choi");
    let user3 = User(id: 3, firstName: "christopher", lastName: "siu");
    let user4 = User(id: 4, firstName: "eric", lastName: "roh");
    let user5 = User(id: 5, firstName: "nancy", lastName: "truong");
    let user6 = User(id: 6, firstName: "david", lastName: "janzen");
    let user7 = User(id: 7, firstName: "dave", lastName: "cool");
    let user8 = User(id: 8, firstName: "jonny", lastName: "appleseed");
    let user9 = User(id: 9, firstName: "loopy", lastName: "doopy");
    let user10 = User(id: 10, firstName: "james", lastName: "wang");
    
    let group1 = Group(id: 1, members: [1, 2, 3, 4], groupName: "one", admin: 1);
    let group2 = Group(id: 2, members: [1, 2], groupName: "two", admin: 1);
    let group3 = Group(id: 3, members: [1, 3], groupName: "three", admin: 1);
    let group4 = Group(id: 4, members: [1, 4], groupName: "four", admin: 1);
    let group5 = Group(id: 5, members: [1, 2, 3], groupName: "five", admin: 1);
    let group6 = Group(id: 6, members: [1, 2, 4], groupName: "six", admin: 1);
    let group7 = Group(id: 7, members: [1, 5, 6, 10], groupName: "seven", admin: 1);
    
    let message1 = Message(id: 1, url: NSURL(string: "")!, groupId: 1, sentFrom: 1, timestamp: NSDate(timeIntervalSince1970:1485123065)
    )
    let message2 = Message(id: 2, url: NSURL(string: "")!, groupId: 2, sentFrom: 2, timestamp: NSDate(timeIntervalSince1970:1485123065 + 10)
    )
    let message3 = Message(id: 3, url: NSURL(string: "")!, groupId: 3, sentFrom: 3, timestamp: NSDate(timeIntervalSince1970:1485123065 + 20)
    )
    let message4 = Message(id: 4, url: NSURL(string: "")!, groupId: 4, sentFrom: 4, timestamp: NSDate(timeIntervalSince1970:1485123065 + 30)
    )
    let message5 = Message(id: 5, url: NSURL(string: "")!, groupId: 5, sentFrom: 2, timestamp: NSDate(timeIntervalSince1970:1485123065 + 40)
    )
    let message6 = Message(id: 6, url: NSURL(string: "")!, groupId: 6, sentFrom: 4, timestamp: NSDate(timeIntervalSince1970:1485123065 + 50)
    )
    let message7 = Message(id: 7, url: NSURL(string: "")!, groupId: 7, sentFrom: 10, timestamp: NSDate(timeIntervalSince1970:1485123065 + 60)
    )
    let message8 = Message(id: 8, url: NSURL(string: "")!, groupId: 1, sentFrom: 3, timestamp: NSDate(timeIntervalSince1970:1485123065 + 70)
    )
    let message9 = Message(id: 9, url: NSURL(string: "")!, groupId: 2, sentFrom: 1, timestamp: NSDate(timeIntervalSince1970:1485123065 + 80)
    )
    let message10 = Message(id: 10, url: NSURL(string: "")!, groupId: 3, sentFrom: 1, timestamp: NSDate(timeIntervalSince1970:1485123065 + 90)
    )
    let message11 = Message(id: 11, url: NSURL(string: "")!, groupId: 4, sentFrom: 1, timestamp: NSDate(timeIntervalSince1970:1485123065 + 100)
    )
    let message12 = Message(id: 12, url: NSURL(string: "")!, groupId: 5, sentFrom: 3, timestamp: NSDate(timeIntervalSince1970:1485123065 + 110)
    )
    let message13 = Message(id: 13, url: NSURL(string: "")!, groupId: 6, sentFrom: 2, timestamp: NSDate(timeIntervalSince1970:1485123065 + 120)
    )
    let message14 = Message(id: 14, url: NSURL(string: "")!, groupId: 7, sentFrom: 6, timestamp: NSDate(timeIntervalSince1970:1485123065 + 130)
    )
    let message15 = Message(id: 15, url: NSURL(string: "")!, groupId: 1, sentFrom: 1, timestamp: NSDate(timeIntervalSince1970:1485123065 + 140)
    )
    let message16 = Message(id: 1, url: NSURL(string: "")!, groupId: 2, sentFrom: 2, timestamp: NSDate(timeIntervalSince1970:1485123065 + 150)
    )
    
    var friendsList: [User];
    var groupList: [Group];
    var messageList: [Message];
    
    init() {
        self.friendsList = [user1, user2, user3, user4, user5, user6, user7, user8, user9, user10];
        self.groupList = [group1, group2, group3, group4, group5, group6, group7];
        self.messageList = [message1, message2, message3, message4, message5, message6, message7, message8, message9, message10, message11, message12, message13, message14, message15, message16];
    }
    
    func getFriendsList() -> [User] {
        return self.friendsList;
    }
    
    func getFriendById(userId: Int) -> User {
        return self.friendsList.filter({ (user) -> Bool in
            return user.id == userId
        })[0];
    }
    
    func getCurrentUser() -> User {
        return user1;
    }
    
    func createGroup(members: [Int], name: String) -> Group {
        let highestId = self.groupList.last!.id;
        let newGroup = Group(id: highestId + 1, members: members, groupName: name, admin: getCurrentUser().id)
        
        self.groupList.append(newGroup);
        
        return newGroup;
    }
    
    func getAllGroups() -> [Group] {
        return self.groupList;
    }
    
    func getGroupById(groupId: Int) -> Group {
        return self.groupList.filter({ (group) -> Bool in
            return group.id == groupId;
        })[0];
    }
    
    func getAllMessagesInGroup(groupId: Int) -> [Message] {
        return self.messageList.filter({ (message) -> Bool in
            message.groupId == groupId;
        });
    }
    
//    func sendMessage(message: Message) {
//        self.messageList.append(message);
//    }
}
