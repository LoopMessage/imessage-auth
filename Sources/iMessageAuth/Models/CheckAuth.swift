//
//  CheckAuth.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import Foundation


struct CheckAuthResponse: Decodable {
    let status: Status
    let sessionToken: String?
    let expireDate: Date?
    let contact: String?
    
    enum Status: String, Codable {
        case pending
        case processing
        case timeout
        case completed
    }
}
