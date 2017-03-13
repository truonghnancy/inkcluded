//
//  CloudStorageAccount.swift
//  inkcluded-405
//
//  Created by Nancy on 3/12/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import AZSClient

class CloudStorageAccount: CloudStorageAccountProtocol {
    var azsAccount: AZSCloudStorageAccount?
    
    required init(){
        do {
            try azsAccount = AZSCloudStorageAccount(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=penmessagestorage;AccountKey=BV5WR1Km404XR6K8F/KxOKuAyTw0utckHVZvOqW/LO5+cUTNVdZ9hShhBS/oOR7VAjKaSlt9+nBVVLXdvRpCgQ==")
        }
        catch {
            print("unable to create azure storage account")
        }
    }
    
    func getBlobStorageClient() -> AZSCloudBlobClient {
        return (azsAccount?.getBlobClient())!
    }
}
