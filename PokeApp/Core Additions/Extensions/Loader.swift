//
//  Loader.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 16/08/21.
//

import UIKit
import JGProgressHUD

extension UIViewController {
    static let hud = JGProgressHUD(style: .dark)
    
    func showLoader(_ show: Bool) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            
            if show {
                UIViewController.hud.show(in: self.view)
            } else {
                UIViewController.hud.dismiss()
            }
        }
    }
}
