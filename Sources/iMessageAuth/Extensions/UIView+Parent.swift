//
//  UIView+Parent.swift
//  
//
//  Created by Andrew on 01/01/2023.
//  Copyright © 2023 Deliany LLC. All rights reserved.
//

import UIKit


extension UIView {
    
    var parentViewController: UIViewController? {
        
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
