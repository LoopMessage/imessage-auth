//
//  UrlSessionManager.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import Foundation


final class UrlSessionManager {
    
    // MARK: - Properties
    private let secretKey: String
    private let authKey: String
    private let urlSession: URLSession
    private(set) var currentTask: URLSessionDataTask?
    
    // MARK: - Init
    init(secretKey: String, authKey: String) {
        self.secretKey = secretKey
        self.authKey = authKey
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        urlSession = URLSession(configuration: configuration)
    }
}

// MARK: - Internal methods
extension UrlSessionManager {
    
    func request<T: Decodable>(route: Router, completion: @escaping (Result<T, AuthError>) -> Void) {
        
        currentTask?.cancel()
        let request = route.request(authKey: authKey, secretKey: secretKey)
        currentTask = urlSession.dataTask(with: request) { [weak self] responseData, response, error in
            
            mainQueue.addOperation { [weak self] in
                
                let httpResponse = response as? HTTPURLResponse
                if let error = error {
                    completion(.failure(.unableToHandleHttpResponse(urlResponseError: error)))
                    return
                }
                guard let statusCode = httpResponse?.statusCode,
                      let responseData = responseData else {
                    completion(.failure(.unableToHandleHttpResponse(urlResponseError: nil)))
                    return
                }
                
                switch statusCode {
                case 200:
                    do {
                        let response = try JSON.decoder.decode(T.self, from: responseData)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.unableToHandleHttpResponse(urlResponseError: error)))
                    }
                case 400:
                    do {
                        let response = try JSON.decoder.decode(GeneralErrorResponse.self, from: responseData)
                        self?.handleErrorCode(code: response.code, completion: completion)
                    } catch {
                        completion(.failure(.badRequest))
                    }
                case 401:
                    completion(.failure(.wrongCredentials))
                case 402: ()
                    completion(.failure(.unpaid))
                case 403:
                    completion(.failure(.unauthorized))
                case 404:
                    completion(.failure(.notFound404))
                case 500...505:
                    completion(.failure(.internalServerError))
                default:
                    completion(.failure(.internalServerError))
                }
            }
        }
        currentTask?.resume()
    }
}

// MARK: - Private methods
private extension UrlSessionManager {
    
    func handleErrorCode<T: Decodable>(code: Int, completion: @escaping (Result<T, AuthError>) -> Void) {
        
        switch code {
        case 120:
            completion(.failure(.missedRequiredParameter))
        case 500:
            completion(.failure(.accountSuspended))
        case 510:
            completion(.failure(.accountBlocked))
        case 700:
            completion(.failure(.invalidBundleId))
        case 710:
            completion(.failure(.unableMakeAuthRequest))
        case 720:
            completion(.failure(.authServiceUnavailable))
        case 730:
            completion(.failure(.invalidRequestId))
        case 740:
            completion(.failure(.invalidAuthDevice))
        case 750:
            completion(.failure(.invalidAuthToken))
        case 760:
            completion(.failure(.authTokenExpired))
        case 770:
            completion(.failure(.deprecatedLibrary))
        default:
            completion(.failure(.badRequest))
        }
    }
}
