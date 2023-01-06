//
//  HTTPMethod.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import Foundation


struct HTTPMethod: Hashable {
    let name: String
}

extension HTTPMethod {
    static let GET = HTTPMethod(name: "GET")
    static let HEAD = HTTPMethod(name: "HEAD")
    static let DELETE = HTTPMethod(name: "DELETE")
    static let POST = HTTPMethod(name: "POST")
    static let PUT = HTTPMethod(name: "PUT")
    static let OPTIONS = HTTPMethod(name: "OPTIONS")
    static let CONNECT = HTTPMethod(name: "CONNECT")
    static let TRACE = HTTPMethod(name: "TRACE")
    static let PATCH = HTTPMethod(name: "PATCH")
}

// MARK: CustomStringConvertible implementation

extension HTTPMethod: CustomStringConvertible {
    var description: String {
        return name
    }
}

// MARK: ExpressibleByStringLiteral implementation

extension HTTPMethod: ExpressibleByStringLiteral {
    init(stringLiteral string: String) {
        self.init(name: string)
    }
}
