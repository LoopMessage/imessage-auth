//
//  ErrorCodes.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany. All rights reserved.
//

import Foundation


public enum AuthError: Error {
    case unpaid
    case deviceCantSendMessages
    case unableToHandleHttpResponse(urlResponseError: Error?)
    case internalServerError
    case requestTimeout
    case canceledByUser
    case messageSendFailed
    case unauthorized
    case wrongCredentials
    case tokenAlreadyRead
    case badRequest
    case notFound404
    case missedRequiredParameter
    case invalidBundleId
    case unableMakeAuthRequest
    case authServiceUnavailable
    case invalidRequestId
    case invalidAuthDevice
    case invalidAuthToken
    case authTokenExpired
    case accountSuspended
    case accountBlocked
    case deprecatedLibrary
}

extension AuthError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .unpaid:
            return App.isTestFlight || App.isDebug ? "Your account with this credentials is unpaid" : "This auth method is currently unavailable"
        case .deviceCantSendMessages:
            return App.isSimulator ? "This feature isn't work on the simulator" : "This device can't send messages"
        case .unableToHandleHttpResponse(let urlResponseError):
            return App.isDebug ? "Failed to process response from server.\n\(urlResponseError?.localizedDescription ?? "")" : "Failed to process response from server. Please check your internet connection or try again later."
        case .internalServerError:
            return "Service temporarily doesn't work, try again later"
        case .requestTimeout:
            return "Auth request timed out"
        case .canceledByUser:
            return "Auth canceled by user"
        case .messageSendFailed:
            return "Failed to send auth code on the user side"
        case .unauthorized:
            return "Session token wrong or expired"
        case .wrongCredentials:
            return "Wrong credentials for iMessage auth"
        case .tokenAlreadyRead:
            return "The token has already been read"
        case .badRequest:
            return "Bad request conditions. Try to check your request parameters."
        case .notFound404:
            return "Error 404, content not found"
        case .missedRequiredParameter:
            return "One or more required parameters for the request are missing"
        case .invalidBundleId:
            return "Invalid or non-existent app bundle id"
        case .unableMakeAuthRequest:
            return "Unable to init auth request. Try again later."
        case .authServiceUnavailable:
            return "The auth service is temporarily unavailable. Try later later."
        case .invalidRequestId:
            return "Invalid or wrong request id"
        case .invalidAuthDevice:
            return "Invalid or wrong auth token"
        case .invalidAuthToken:
            return "Invalid auth token"
        case .authTokenExpired:
            return "Auth token has expired"
        case .accountSuspended:
            return App.isTestFlight || App.isDebug ? "Your credentials have been suspended and can't be used for further requests." : "This auth method is currently unavailable"
        case .accountBlocked:
            return App.isTestFlight || App.isDebug ? "Your credentials have been blocked and can't be used for further requests." : "This auth method is currently unavailable"
        case .deprecatedLibrary:
            return App.isTestFlight || App.isDebug ? "The Library version that you use is deprecated. Please update it with your dependency manager." : "This auth method is currently unavailable"
        }
    }
}
