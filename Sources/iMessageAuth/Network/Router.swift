//
//  Router.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import Foundation


private let kApplicationJSON = "application/json"
private let kConnectionClose = "close"
private let kSessionToken = "Auth-Session-Token"
private let kSecretKey = "Auth-Secret-Key"
private let kRegionCode = "App-Region-Code"
private let kAppEnv = "App-Environment"
private let kAppBundleId = "App-Bundle-Id"
private let klibraryVersion = "Library-Version"
private let kAppVersion = "App-Version"
private let kAppName = "App-Name"
private let kAppBuild = "App-Build"
private let kAppLocaleIdentifier = "App-Locale-Identifier"
private let kDeviceId = "Device-Id"

enum Router {
    
    case initAuth
    case checkAuth(id: String)
    case validateSession(token: String)
    
    var path: String {
        switch self {
        case .initAuth:
            return "auth/api/v1/init/"
        case .checkAuth(let id):
            return "auth/api/v1/init/\(id)/"
        case .validateSession:
            return "auth/api/v1/check-session/"
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .initAuth, .checkAuth:
            return nil
        case .validateSession(let token):
            return [kSessionToken: token]
        }
    }
    
    var method: String {
        switch self {
        case .initAuth:
            return HTTPMethod.POST.name
        case .checkAuth, .validateSession:
            return HTTPMethod.GET.name
        }
    }
    
    var httpBody: Data? {
        switch self {
        case .initAuth, .checkAuth, .validateSession:
            return nil
        }
    }
    
    var requestURL: URL? {
        return URL(string: App.baseURL + path)
    }
    
    func request(authKey: String, secretKey: String) -> URLRequest {
        
        guard let requestURL = requestURL else {
            fatalError("Unable to generate request URL 🚨")
        }
        var request = URLRequest(url: requestURL)
        // Headers
        request.addValue(kApplicationJSON, forHTTPHeaderField: HTTPHeaderName.contentType.description)
        request.addValue(authKey, forHTTPHeaderField: HTTPHeaderName.authorization.description)
        request.addValue(secretKey, forHTTPHeaderField: kSecretKey)
        request.addValue(kConnectionClose, forHTTPHeaderField: HTTPHeaderName.connection.description)
        request.addValue(App.environment, forHTTPHeaderField: kAppEnv)
        request.addValue(App.deviceId, forHTTPHeaderField: kDeviceId)
        
        if let region = Locale.current.regionCode {
            request.addValue(region, forHTTPHeaderField: kRegionCode)
        }
        request.addValue(App.bundleId, forHTTPHeaderField: kAppBundleId)
        request.addValue(App.version, forHTTPHeaderField: kAppVersion)
        request.addValue(App.build, forHTTPHeaderField: kAppBuild)
        request.addValue(App.name, forHTTPHeaderField: kAppName)
        request.addValue(Locale.current.identifier, forHTTPHeaderField: kAppLocaleIdentifier)
        
        let libraryVersionKey = App.isMacOS ? "\(klibraryVersion)-MAC" : "\(klibraryVersion)-IOS"
        request.addValue(App.version(for: AppleMessagesAuth.self), forHTTPHeaderField: libraryVersionKey)
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        // Body
        request.httpBody = httpBody
        // Mehtod
        request.httpMethod = method
        // Timeout interval
        request.timeoutInterval = 30
        
        return request
    }
}
