//
//  APICallTests.swift
//  inkcluded-405
//
//  Created by Nancy on 3/11/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import XCTest
@testable import inkcluded_405

class APICallTests: XCTestCase {
    
    var apiCalls : APICalls!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        apiCalls = APICalls.sharedInstance
        
        apiCalls.client.login
    }
    
//    func testLogin() {
//        apiCalls.login(closure: {
//        (user) in
//            
//        })
//    }
    
    func testFindByEmail() {
        apiCalls.findUserByEmail(email: "josh14231@gmail.com", closure: {
            (users) in
                print(users![0].firstName, "hello")
                XCTAssertEqual(users![0].firstName, "Josh")
        })
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
