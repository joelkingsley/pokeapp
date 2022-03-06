//
//  AuthenticationViewModel.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 15/08/21.
//

import UIKit

protocol AuthenticationViewModel {
    var formIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
    var buttonTitleColor: UIColor { get }
}
