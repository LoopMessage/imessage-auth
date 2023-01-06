//
//  SecondViewController.swift
//  iMessageAuth_Example
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import UIKit
import iMessageAuth

final class SecondViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var tokenExpireDate: Date!
    var sessionToken: String!
    var contact: String!
    var iMessageAuth: AppleMessagesAuth!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillValues(valid: tokenExpireDate >= Date(), expireDate: tokenExpireDate, contact: contact)
    }
    
    func fillValues(valid: Bool, expireDate: Date, contact: String) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        let date = Date()
        statusLabel.text = "Token valid - \(valid)\nExpire date: \(formatter.string(from: expireDate))\nLast check date: \(formatter.string(from: date))\nContact: \(contact)"
        statusLabel.textColor = .green
    }
}

// MARK: - IBActions
private extension SecondViewController {
    
    @IBAction func checkToken(_ sender: UIButton) {
        
        activityIndicator.startAnimating()
        sender.isUserInteractionEnabled = false
        
        iMessageAuth.checkSession(token: sessionToken) { [weak self] result in
            
            switch result {
            case .success(let response):
                self?.fillValues(valid: response.valid, expireDate: response.expireDate, contact: response.contact ?? "")
            case .failure(let error):
                self?.statusLabel.text = error.localizedDescription
                self?.statusLabel.textColor = .red
            }
            self?.activityIndicator.stopAnimating()
            sender.isUserInteractionEnabled = true
        }
    }
}
