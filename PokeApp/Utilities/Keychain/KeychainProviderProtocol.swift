//
//  KeychainProviderProtocol.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 16/08/21.
//

import Foundation

protocol KeychainProviderProtocol {
    static func getIdToken() -> String
    static func setIdToken(idToken: String)
    static func removeIdToken()
    
    static func getRefreshToken() -> String
    static func setRefreshToken(refreshToken: String)
    static func removeRefreshToken()
}
