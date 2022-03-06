//
//  RegistrationResponse.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 16/08/21.
//

import Foundation

struct RegistrationResponse: Decodable {
    let idToken: String
    let displayName: String
    let email: String
    let refreshToken: String
    let expiresIn: String
    let localId: String
}
