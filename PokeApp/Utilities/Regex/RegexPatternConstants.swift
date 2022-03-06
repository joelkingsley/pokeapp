//
//  RegexPattern.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 17/08/21.
//

import Foundation

struct RegexPatternConstants {
    static let email = #"^\S+@\S+\.\S+$"#
    static let password = #"(?=.{6,})"#
    static let displayName = #"(?<! )[-a-zA-Z' ]{2,26}"#
}
