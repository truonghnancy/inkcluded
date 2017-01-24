//
//  APIWrapperTest.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/24/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import XCTest

class APIWrapperTest: XCTestCase {
    
    var apiWrapper: APIWrapper!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        apiWrapper = APIWrapper()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        apiWrapper = nil
    }
    
    func testGetFriendsList() {
        let friendsList = apiWrapper.getFriendsList()
        XCTAssertEqual(friendsList.count, 10)
        XCTAssertEqual(friendsList[0].id, 1)
        XCTAssertEqual(friendsList[0].firstName, "francis")
        XCTAssertEqual(friendsList[0].lastName, "yuen")
    }
    
    func testGetFriendById() {
        let friend1 = apiWrapper.getFriendById(userId: 1)
        XCTAssertEqual(friend1.id, 1)
        XCTAssertEqual(friend1.firstName, "francis")
        XCTAssertEqual(friend1.lastName, "yuen")
        
        let friend5 = apiWrapper.getFriendById(userId: 5)
        XCTAssertEqual(friend5.id, 5)
        XCTAssertEqual(friend5.firstName, "nancy")
        XCTAssertEqual(friend5.lastName, "truong")
        
        let friend10 = apiWrapper.getFriendById(userId: 10)
        XCTAssertEqual(friend10.id, 10)
        XCTAssertEqual(friend10.firstName, "james")
        XCTAssertEqual(friend10.lastName, "wang")
    }
    
    func testGetCurrentUser() {
        let curUser = apiWrapper.getCurrentUser();
        XCTAssertEqual(curUser.id, 1)
        XCTAssertEqual(curUser.firstName, "francis")
        XCTAssertEqual(curUser.lastName, "yuen")
    }
    
    func testCreateGroup() {
        let newGroup = apiWrapper.createGroup(members: [1, 2, 3], name: "newGroup")
        let allGroups = apiWrapper.getAllGroups()
        
        let result = allGroups.filter { (group) -> Bool in
            group.id == newGroup.id
        }
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].members, [1, 2, 3])
        XCTAssertEqual(result[0].groupName, "newGroup")
        XCTAssertEqual(result[0].admin, 1)
        XCTAssertEqual(result[0].id, newGroup.id)
    }
    
    func testGetAllGroups() {
        let allGroups = apiWrapper.getAllGroups()
        
        XCTAssertEqual(allGroups.count, 7)
        XCTAssertEqual(allGroups[0].id, 1)
        XCTAssertEqual(allGroups[3].id, 4)
        XCTAssertEqual(allGroups[5].id, 6)
    }
    
    func testGetGroupById() {
        let group = apiWrapper.getGroupById(groupId: 5)
        
        XCTAssertEqual(group.id, 5)
        XCTAssertEqual(group.members, [1, 2, 3]);
        XCTAssertEqual(group.admin, 1);
        XCTAssertEqual(group.groupName, "five");
    }
    
    func testGetAllMessagesInGroup() {
        let allMessages = apiWrapper.getAllMessagesInGroup(groupId: 1)
        let validIds = [1, 8, 15]
        
        XCTAssertEqual(allMessages.count, 3)
        XCTAssertTrue(validIds.contains(allMessages[0].id))
        XCTAssertTrue(validIds.contains(allMessages[1].id))
        XCTAssertTrue(validIds.contains(allMessages[2].id))
    }
    
    func testSendMessage() {
        
    }
}
