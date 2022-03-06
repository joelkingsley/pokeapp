//
//  RegexValidationProviderProtocol.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 17/08/21.
//

import Foundation

protocol RegexValidationProviderProtocol {
    static func validate(target: String, with regexPattern: String) -> Bool
}
