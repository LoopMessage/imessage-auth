//
//  ViewController.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import UIKit
import iMessageAuth

final class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var signInButton: UIButton!
    @IBOutlet private var errorLabel: UILabel!
    
    // MARK: - Properties
    // Set here auth key and secret key
    let iMessageAuth = AppleMessagesAuth(authKey: "", secretKey: "")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.text = nil
    }
}

// MARK: - IBActions
private extension ViewController {
    
    @IBAction func signIn(_ sender: UIButton) {
        errorLabel.text = nil
        iMessageAuth.initAuth(from: self, sender: sender, delegate: self)
    }
}

// MARK: - AppleMessagesAuthDelegate
extension ViewController: AppleMessagesAuthDelegate {
    
    func didInitAuth(id: String) {
        // ID of your request
    }
    
    func authDidFailed(error: AuthError) {
        // Handle error codes
        errorLabel.text = error.localizedDescription
    }
    
    func authDidFinished(sessionToken: String, tokenExpirationDate: Date, contact: String) {
        // Save this token in the Keychain
        let controller = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondViewController.self)) as? SecondViewController
        controller?.tokenExpireDate = tokenExpirationDate
        controller?.sessionToken = sessionToken
        controller?.iMessageAuth = iMessageAuth
        controller?.contact = contact
        self.navigationController?.pushViewController(controller!, animated: true)
    }
}
