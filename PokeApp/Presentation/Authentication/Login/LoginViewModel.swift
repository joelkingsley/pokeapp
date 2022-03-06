//
//  LoginViewModel.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 15/08/21.
//

import UIKit

struct LoginViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        guard let email = email else { return false }
        guard let password = password else { return false }
        
        let isEmailValid = !email.isEmpty && RegexValidationProvider.validate(target: email, with: RegexPatternConstants.email)
        let isPasswordValid = !password.isEmpty && RegexValidationProvider.validate(target: password, with: RegexPatternConstants.password)
        
        return isEmailValid && isPasswordValid
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
}
