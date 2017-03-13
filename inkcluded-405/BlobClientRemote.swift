//
//  BlobClient.swift
//  inkcluded-405
//
//  Created by Nancy on 3/12/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import AZSClient

protocol BlobClientProtocol {
    func containerReference(fromName: String) -> AZSCloudBlobContainer
}
