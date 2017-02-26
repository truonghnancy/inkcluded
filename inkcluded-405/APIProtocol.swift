//
//  APIProtocol.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/22/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation

protocol APIProtocol {
    func getFriendsList() -> [User];
//    func getFriendById(userId: Int) -> User;
    
//    func getCurrentUser() -> User;
    
    func createGroup(members: [User], name: String);
    func getAllGroups() -> [Group];
//    func getGroupById(groupId: Int) -> Group;
    
//    func getAllMessagesInGroup(groupId: Int) -> [Message];
//    func sendMessage(message: Message);
}
