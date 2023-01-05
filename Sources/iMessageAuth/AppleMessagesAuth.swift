//
//  AppleMessagesAuth.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import UIKit


public protocol AppleMessagesAuthDelegate: AnyObject {
    /// The authorization process has been started. You can save the request ID so that you can continue checking a little bit later if the user accidentally closes the application or auth screen. Each ID has an expiration time.
    /// - Parameter id: The unique ID of the auth request.
    func didInitAuth(id: String)
    
    /// Unable to process your auth request. Check the error parameter for details.
    /// - Parameter error: Enum with authorization errors. Supports the Error protocol.
    /// The localizedDescription property is in English only. It is not recommended to show localizedDescription from errors to users in production.
    func authDidFailed(error: AuthError)
    
    /// The authorization process has been completed.
    /// - Parameters:
    ///   - sessionToken: Your session token. You can store it locally in the keychain and then check it with the "`func checkSession(token:string)`" method, or compare it to what you get from the backend (if using a server to receive auth callbacks).
    ///   - tokenExpirationDate: Date until which the token will be valid.
    ///   - contact: Phone number or Email of the user that was used for Sign In via iMessage.
    func authDidFinished(sessionToken: String, tokenExpirationDate: Date, contact: String)
}

public extension AppleMessagesAuthDelegate {
    
    func didInitAuth(id: String) { }
}

open class AppleMessagesAuth {
    
    /// Configuration for customizing the auth process
    public struct Configuration {
        let showLoader: Bool
        let isUserInteractionEnabled: Bool
        let requestTimeout: TimeInterval
        
        /// - Parameters:
        ///   - showLoader: Whether to display Loader when sending a request. An AcitivtyIndicator will be displayed in the center of the ViewController from which you will call the initAuth function.
        ///   - isUserInteractionEnabled: Whether to disable UserInteraction/Enabled parameter during the request. Will be applied to the object that is passed in the "sender" parameter. Otherwise, the parameter has no effect.
        ///   - requestTimeout: The time during which, if it was not possible to get the result of auth requests, will be considered as timed out. The value can't be less than 30 seconds and more than 300 seconds. This setting will help avoid cases with infinite loader if a user has a bad internet connection or takes the longest time to process their request.
        public init(showLoader: Bool = true,
                    isUserInteractionEnabled: Bool = true,
                    requestTimeout: TimeInterval = 90) {
            self.showLoader = showLoader
            self.isUserInteractionEnabled = isUserInteractionEnabled
            
            let minValue: TimeInterval = 30 // 30 sec
            let maxValue: TimeInterval = 300 // 300 sec/5 mins
            switch requestTimeout {
            case _ where requestTimeout < minValue:
                self.requestTimeout = minValue
            case _ where requestTimeout > maxValue:
                self.requestTimeout = maxValue
            default:
                self.requestTimeout = requestTimeout
            }
        }
    }
    
    // MARK: - Properties
    private(set) weak var delegate: AppleMessagesAuthDelegate?
    private var composerHelper: ComposerHelper?
    private let urlSession: UrlSessionManager
    private let configuration: Configuration
    private let activityView: UIActivityIndicatorView?
    
    
    /// - Parameters:
    ///   - authKey: Auth Key which you can get on the home page in service Dashboard - https://dashboard.loopmessage.com/
    ///   - secretKey: Secret Key of your application. Each application has its own unique secret key which is generated when you create a new bundle id in the dashboard.
    ///   - configuration: Custom configuration
    public init(authKey: String, secretKey: String, configuration: Configuration = Configuration()) {
        self.configuration = configuration
        
        if configuration.showLoader {
            activityView = UIActivityIndicatorView(style: .whiteLarge)
            activityView?.startAnimating()
        } else {
            activityView = nil
        }
        
        urlSession = UrlSessionManager(secretKey: secretKey, authKey: authKey)
    }
}

// MARK: - Public methods
public extension AppleMessagesAuth {
    
    
    /// Initializing an auth request via iMessage. Once the request completes, a MessageComposer will be presented to a user to send the auth code from iMessage. After that, within a few seconds, the service will check the delivered code.
    /// - Parameters:
    ///   - controller: ViewController from which will be presented MessageComposer
    ///   - sender: The object that performed the action
    ///   - delegate: Auth delegate object
    func initAuth(from controller: UIViewController, sender: Any? = nil, delegate: AppleMessagesAuthDelegate) {
        
        self.delegate = delegate
        
        guard canSendText else {
            self.delegate?.authDidFailed(error: AuthError.deviceCantSendMessages)
            return
        }
        
        if let activityView = activityView {
            activityView.center = controller.view.center
            controller.view.addSubview(activityView)
        }
        handleUserInteraction(isEnabled: false, sender: sender)
        
        initAuthRequests { [weak self] response in
            switch response {
            case .success(let response):
                self?.composerHelper = ComposerHelper(
                    rootViewController: controller,
                    recipient: response.senderName,
                    text: response.text) { [weak self] result in
                        
                        mainQueue.addOperation { [weak self] in
                            guard let self = self else { return }
                            switch result {
                            case .sent:
                                let timeoutDate = Date() + self.configuration.requestTimeout
                                self.startCheckAuthRequest(id: response.requestId, timeoutDate: timeoutDate, controller: controller, sender: sender)
                            case .failed:
                                self.delegate?.authDidFailed(error: .messageSendFailed)
                                self.handleUserInteraction(isEnabled: true, sender: sender)
                            case .cancelled:
                                self.delegate?.authDidFailed(error: .canceledByUser)
                                self.handleUserInteraction(isEnabled: true, sender: sender)
                            @unknown default:
                                self.delegate?.authDidFailed(error: .messageSendFailed)
                                self.handleUserInteraction(isEnabled: true, sender: sender)
                            }
                        }
                    }
            case .failure(let error):
                mainQueue.addOperation { [weak self] in
                    self?.delegate?.authDidFailed(error: error)
                    self?.handleUserInteraction(isEnabled: true, sender: sender)
                }
            }
        }
    }
    
    /// Request to continue the auth check. It can be useful if the user accidentally closed the application or auth screen. Each `requestId` has an expiration time.
    /// - Parameters:
    ///   - requestId: The request id that you received from the "func didInitAuth(id: String)" delegate method.
    ///   - controller: ViewController from which will be presented MessageComposer
    ///   - sender: The object that performed the action
    ///   - delegate: Auth delegate object
    func checkAuthRequest(requestId: String, controller: UIViewController, sender: Any? = nil, delegate: AppleMessagesAuthDelegate) {
        
        if let activityView = activityView {
            activityView.center = controller.view.center
            controller.view.addSubview(activityView)
        }
        handleUserInteraction(isEnabled: true, sender: sender)
        
        let timeoutDate = Date() + configuration.requestTimeout
        self.startCheckAuthRequest(id: requestId, timeoutDate: timeoutDate, controller: controller, sender: sender)
    }
    
    /// Token validity check. Use this method if you are using client-side authentication (without using a server). Otherwise, it is recommended to do the validation on your backend.
    /// - Parameters:
    ///   - token: Session token
    ///   - completion: Return TokenValidationResponse or AuthError. If success, the model will contain information about your session.
    func checkSession(token: String, completion: @escaping (Result<TokenValidationResponse, AuthError>) -> Void) {
        
        checkSessionToken(token: token) { result in
            switch result {
            case .success(let response):
                mainQueue.addOperation {
                    response.valid ? completion(.success(response)) : completion(.failure(.invalidAuthToken))
                }
            case .failure(let error):
                mainQueue.addOperation {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Private methods
private extension AppleMessagesAuth {
    
    func handleUserInteraction(isEnabled: Bool, sender: Any?) {
        
        if isEnabled, let activityView = activityView {
            activityView.removeFromSuperview()
        }
        
        guard !configuration.isUserInteractionEnabled else { return }
        
        if let sender = sender as? UIViewController {
            sender.view.isUserInteractionEnabled = isEnabled
        } else if let sender = sender as? UIButton {
            sender.isEnabled = isEnabled
        } else if let sender = sender as? UIView {
            sender.isUserInteractionEnabled = isEnabled
        } else if let sender = sender as? UIBarButtonItem {
            sender.isEnabled = isEnabled
        } else if let sender = sender as? UIGestureRecognizer {
            sender.isEnabled = isEnabled
        }
    }
   
    func startCheckAuthRequest(id: String, timeoutDate: Date, controller: UIViewController, sender: Any?) {
        
        guard timeoutDate >= Date() else {
            delegate?.authDidFailed(error: .requestTimeout)
            handleUserInteraction(isEnabled: true, sender: sender)
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            
            guard let self = self else { return }
            
            self.checkAuthRequest(id: id) { result in
                switch result {
                case .success(let response):
                    
                    switch response.status {
                    case .pending, .processing:
                        self.startCheckAuthRequest(id: id, timeoutDate: timeoutDate, controller: controller, sender: sender)
                    case .timeout:
                        self.delegate?.authDidFailed(error: .requestTimeout)
                        self.handleUserInteraction(isEnabled: true, sender: sender)
                    case .completed:
                        if let sessionToken = response.sessionToken,
                           let contact = response.contact,
                           let expireDate = response.expireDate {
                            self.delegate?.authDidFinished(sessionToken: sessionToken,
                                                           tokenExpirationDate: expireDate,
                                                           contact: contact)
                        } else {
                            self.delegate?.authDidFailed(error: .tokenAlreadyRead)
                        }
                        self.handleUserInteraction(isEnabled: true, sender: sender)
                    }
                case .failure(let error):
                    self.delegate?.authDidFailed(error: error)
                    self.handleUserInteraction(isEnabled: true, sender: sender)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }
    
    func initAuthRequests(completion: @escaping (Result<InitAuthResponse, AuthError>) -> Void) {
        urlSession.request(route: .initAuth, completion: completion)
    }
    
    func checkAuthRequest(id: String, completion: @escaping (Result<CheckAuthResponse, AuthError>) -> Void) {
        urlSession.request(route: .checkAuth(id: id), completion: completion)
    }
    
    func checkSessionToken(token: String, completion: @escaping (Result<TokenValidationResponse, AuthError>) -> Void) {
        urlSession.request(route: .validateSession(token: token), completion: completion)
    }
}
