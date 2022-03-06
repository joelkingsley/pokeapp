//
//  CustomTextButton.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 13/08/21.
//

import UIKit

class CustomTextButton: UIButton {
    
    func setCustomAttributedTitle(firstPart: String, secondPart: String) {
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1, alpha: 0.87), .font: UIFont.systemFont(ofSize: 16)]
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart) ", attributes: atts)
        
        let boldAtts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1, alpha: 0.87), .font: UIFont.boldSystemFont(ofSize: 16)]
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: boldAtts))
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func setLinkStyleAttributedTitle(text: String) {
        let atts: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Futura Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)]
        let attributedTitle = NSMutableAttributedString(string: text, attributes: atts)
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
}
