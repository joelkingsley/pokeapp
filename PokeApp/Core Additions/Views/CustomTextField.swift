//
//  CustomTextField.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 13/08/21.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeHolder: String = "Enter Here") {
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: CGFloat(50)).isActive = true
        spacer.widthAnchor.constraint(equalToConstant: CGFloat(12)).isActive = true
        leftView = spacer
        leftViewMode = .always

        font = UIFont(name: "Futura Medium", size: 16)
        borderStyle = .none
        textColor = .white
        keyboardAppearance = .dark
        keyboardType = .default
        backgroundColor = UIColor(white: 1, alpha: 0.1)
        heightAnchor.constraint(equalToConstant: CGFloat(50)).isActive = true
        attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
