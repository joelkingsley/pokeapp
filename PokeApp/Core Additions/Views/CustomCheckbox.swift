//
//  CustomCheckbox.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 06/09/21.
//

import UIKit

class CustomCheckbox: UIButton {
    private let checkedImage = #imageLiteral(resourceName: "icons8-filled-checked-50")
    private let uncheckedImage = #imageLiteral(resourceName: "icons8-circle-50")
    
    var shouldDisable: Bool = false {
        didSet {
            if shouldDisable == true {
                isEnabled = false
                tintColor = .lightGray
            } else {
                isEnabled = true
                tintColor = .black
            }
        }
    }
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setBackgroundImage(checkedImage.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                self.setBackgroundImage(uncheckedImage.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }
}
