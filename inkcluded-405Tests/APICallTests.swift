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
    
    // Nancy Truong
    // Testing if you can retrieve a user from a table
    func testLoginValidUser() {
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
            var mUser: MSUser
            init(user: MSUser) {
                self.mUser = user
                super.init()
            }
            
            
            override func read(completion: MSReadQueryBlock? = nil) {
                completion?(
                    MSQueryResult(items: [["id" : "bleh", "firstName": "Enrique", "lastName": "Siu"]], totalCount: 1, nextLink: "none"),
                    nil)
            }
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
        
        let mockUser = mockMSUser(userId: "enrique")
        let mockClient = mockMSClient(user: mockUser)
        let mockQuery = mockMSQuery(user: mockUser)
        let mockTable = mockMSTable(name: "User", client: mockClient, query: mockQuery)
        mockClient.setTable(mTable: mockTable)
        let mockBlob = mockBlobStorage()
        let mockAzsAccount = mockAZSAccount(mBlobStorage: mockBlob)
        let apiCalls = APICalls(mClient: mockClient, mAzsAccount: mockAzsAccount)
        
        apiCalls.login(closure:
            {(userEntry) -> Void in
                XCTAssertNotNil(userEntry)
                XCTAssertEqual(userEntry?.id, "bleh")
                XCTAssertEqual(userEntry?.firstName, "Enrique")
                XCTAssertEqual(userEntry?.lastName, "Siu")
        })
    }
    
    // Nancy Truong
    // Testing if there's no existing user and adding a new one
    func testLoginNoUser() {
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
            
            override func insert(_ item: [AnyHashable : Any], completion: MSItemBlock? = nil) {
                completion?(["id" : "bleh", "firstName": "Enrique", "lastName": "Siu"], nil)
            }
        }
        // mock query
        class mockMSQuery: MSQuery {
            var mUser: MSUser
            init(user: MSUser) {
                self.mUser = user
                super.init()
            }
            
            override func read(completion: MSReadQueryBlock? = nil) {
                completion?(nil, NSError(domain: "test", code: 404, userInfo: nil))
            }
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
        
        let mockUser = mockMSUser(userId: "enrique")
        let mockClient = mockMSClient(user: mockUser)
        let mockQuery = mockMSQuery(user: mockUser)
        let mockTable = mockMSTable(name: "User", client: mockClient, query: mockQuery)
        mockClient.setTable(mTable: mockTable)
        let mockBlob = mockBlobStorage()
        let mockAzsAccount = mockAZSAccount(mBlobStorage: mockBlob)
        let apiCalls = APICalls(mClient: mockClient, mAzsAccount: mockAzsAccount)
        
        
        // Testing if there are no users in the User table
        apiCalls.login(closure:
            {(userEntry) -> Void in
                //XCTAssertNil(userEntry)
                XCTAssertNotNil(userEntry)
                XCTAssertEqual(userEntry?.id, "bleh")
                XCTAssertEqual(userEntry?.firstName, "Enrique")
                XCTAssertEqual(userEntry?.lastName, "Siu")
        })
    }
    
    // Nancy Truong
    // Testing if there's no existing user and error adding a new one
    func testLoginNoUserError() {
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
            
            override func insert(_ item: [AnyHashable : Any], completion: MSItemBlock? = nil) {
                completion?(nil, NSError(domain: "test", code: 404, userInfo: nil))
            }
        }
        // mock query
        class mockMSQuery: MSQuery {
            var mUser: MSUser
            init(user: MSUser) {
                self.mUser = user
                super.init()
            }
            
            override func read(completion: MSReadQueryBlock? = nil) {
                completion?(nil, NSError(domain: "test", code: 404, userInfo: nil))
            }
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
        
        let mockUser = mockMSUser(userId: "enrique")
        let mockClient = mockMSClient(user: mockUser)
        let mockQuery = mockMSQuery(user: mockUser)
        let mockTable = mockMSTable(name: "User", client: mockClient, query: mockQuery)
        mockClient.setTable(mTable: mockTable)
        let mockBlob = mockBlobStorage()
        let mockAzsAccount = mockAZSAccount(mBlobStorage: mockBlob)
        let apiCalls = APICalls(mClient: mockClient, mAzsAccount: mockAzsAccount)
        
        
        // Testing if there are no users in the User table
        apiCalls.login(closure:
            {(userEntry) -> Void in
                XCTAssertNil(userEntry)
        })
    }
}
