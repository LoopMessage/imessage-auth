//
//  GeneralErrorResponse.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import Foundation


struct GeneralErrorResponse: Decodable {
    let success: Bool?
    let code: Int
}
