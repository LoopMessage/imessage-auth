//
//  App.swift
//  LoopServer
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import Foundation
import AdSupport
import UIKit

let mainQueue = OperationQueue.main

struct App {
    
    static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    static let isDebug: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()
    static let isMacOS: Bool = {
        #if os(macOS)
            return true
        #else
            return false
        #endif
    }()
    
    static let baseURL: String = {
        return "https://loop-server-dev-gedmh.ondigitalocean.app/"
    }()
    
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
    
    static let environment: String = {
        if isDebug {
            return "xcode"
        } else if isTestFlight {
            return "tf"
        } else {
            return "prod"
        }
    }()
    
    static let name: String = {
        Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "???"
    }()
    
    static let bundleId: String = {
        Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "???"
    }()
    
    static let build: String = {
        Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "???"
    }()
    
    static let version: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    }()
    
    static func version(for anyclass: AnyClass) -> String {
        Bundle(for: anyclass).infoDictionary?["CFBundleShortVersionString"] as? String ?? "???"
    }
    
    static func isAdvertisingTrackingEnabled() -> Bool {
        ASIdentifierManager.shared().isAdvertisingTrackingEnabled
    }
    static func identifierForAdvertising() -> String? {
        // Check whether advertising tracking is enabled
        guard isAdvertisingTrackingEnabled() else {
            return nil
        }
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    static let idfv: String? = {
        return UIDevice.current.identifierForVendor?.uuidString
    }()
    
    static let deviceId: String = {
        let kDeviceId = "iMessageAuthDeviceId"
        if let deviceId = UserDefaults.standard.string(forKey: kDeviceId) {
            return deviceId
        } else {
            let deviceId = idfv ?? UUID().uuidString
            UserDefaults.standard.set(deviceId, forKey: kDeviceId)
            return deviceId
        }
    }()
}
