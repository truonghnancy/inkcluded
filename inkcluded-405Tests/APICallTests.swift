//
//  APICallTests.swift
//  inkcluded-405
//
//  Created by Nancy on 3/11/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import XCTest
@testable import inkcluded_405
import AZSClient

class APICallTests: XCTestCase {
    
    var apiCalls : APICalls!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //APICalls.sharedInstance
        apiCalls = APICalls.sharedInstance
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // mock MSClient
        class mockMSClient: MSClient {
            init(user: MSUser) {
                super.init()
                self.currentUser = user
            }
        }
        // mock MSUser
        class mockMSUser: MSUser {
            
        }
        // mock azure storage account
        class mockAZSAccount: AZSCloudStorageAccount {
            
        }
        
        var mockClient = mockMSClient(user: mockMSUser())
        var mockAzsAccount = mockAZSAccount()
        var apiCalls = APICalls(mClient: mockClient, mAzsAccount: mockAzsAccount)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
