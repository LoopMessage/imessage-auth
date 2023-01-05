//
//  ComposerHelper.swift
//  iMessageAuth
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import UIKit
import Messages
import MessageUI


var canSendText: Bool {
    return MFMessageComposeViewController.canSendText()
}


final class ComposerHelper: NSObject {
    
    // MARK: - Properties
    let messageController: MFMessageComposeViewController
    private var completion: (MessageComposeResult) -> Void
    
    // MARK: - Init
    init(rootViewController controller: UIViewController,
         recipient: String, text: String,
         completion: @escaping (MessageComposeResult) -> Void) {
        let messageController = MFMessageComposeViewController()
        messageController.disableUserAttachments()
        messageController.recipients = [recipient]
        messageController.body = text
        self.messageController = messageController
        self.completion = completion
        super.init()
        messageController.messageComposeDelegate = self
        
        controller.present(messageController, animated: true) {
            messageController.setNavigationBarHidden(true, animated: false)
        }
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension ComposerHelper: MFMessageComposeViewControllerDelegate {
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        completion(result)
        controller.dismiss(animated: true)
    }
}
