//
//  InitAuthRequest.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import Foundation


struct InitAuthResponse: Decodable {
    let requestId: String
    let code: String
    let senderName: String
    let text: String
    let imessageLink: String?
    let qrCode: String?
    let expiryDate: Date?
}
