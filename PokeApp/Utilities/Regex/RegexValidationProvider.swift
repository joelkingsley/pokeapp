//
//  RegexValidationProvider.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 17/08/21.
//

import Foundation

struct RegexValidationProvider: RegexValidationProviderProtocol {
    static func validate(target: String, with regexPattern: String) -> Bool {
        let result = target.range(
            of: regexPattern,
            options: .regularExpression
        )
        return (result != nil)
    }
}
