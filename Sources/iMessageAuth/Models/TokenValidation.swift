//
//  TokenValidation.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import Foundation


struct TokenValidationRequest: Decodable {
    let token: String
}

public struct TokenValidationResponse: Decodable {
    public let valid: Bool
    public let expireDate: Date
    public let contact: String?
}
