//
//  LoginResponse.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 15/08/21.
//

import Foundation

struct LoginResponse: Decodable {
    let displayName: String
    let email: String
    let expiresIn: String
    let localId: String
    let idToken: String
    let refreshToken: String
    let registered: Bool
}
