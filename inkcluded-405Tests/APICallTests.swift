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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin() {
        // mock MSClient
        class mockMSClient: MSClient {
            var table: MSTable?
            
            init(user: MSUser) {
                super.init()
                self.currentUser = user
            }
            
            func setTable(mTable: MSTable) {
                self.table = mTable
            }
            
            override func table(withName tableName: String) -> MSTable {
                return self.table!
            }
            
        }
        // mock MSUser
        class mockMSUser: MSUser {
            
        }
        // mock MSTable
        class mockMSTable: MSTable {
            var myQuery: MSQuery
            
            init(name tableName: String, client: MSClient, query: MSQuery) {
                self.myQuery = query
                super.init(name: tableName, client: client)
            }
            
            override func query(with predicate: NSPredicate) -> MSQuery {
                return myQuery
            }
            
        }
        // mock query
        class mockMSQuery: MSQuery {
            
        }
        // mock azure storage account
        class mockAZSAccount: CloudStorageAccountProtocol {
            var blobStorage: BlobClientProtocol
            
            init(mBlobStorage: BlobClientProtocol) {
                self.blobStorage = mBlobStorage
            }
            
            func getBlobStorageClient() -> BlobClientProtocol {
                return self.blobStorage
            }
        }
        // mock azure blob storage
        class mockBlobStorage: BlobClientProtocol {
            func containerReference(fromName: String) -> AZSCloudBlobContainer {
                return mockBlobContainer()
            }
        }
        // mock azure blob container
        class mockBlobContainer: AZSCloudBlobContainer {
            
        }
        
        let mockClient = mockMSClient(user: mockMSUser(userId: "enrique"))
        let mockQuery = mockMSQuery()
        let mockTable = mockMSTable(name: "User", client: mockClient, query: mockQuery)
        mockClient.setTable(mTable: mockTable)
        let mockBlob = mockBlobStorage()
        let mockAzsAccount = mockAZSAccount(mBlobStorage: mockBlob)
        let apiCalls = APICalls(mClient: mockClient, mAzsAccount: mockAzsAccount)
        
        
        // Testing if there are no users in the User table
        apiCalls.login(closure:
            {(userEntry) -> Void in
                XCTAssertNotNil(userEntry)
        })
        
        // Testing if there's a valid user in the User table
        //mockTable.ins
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
