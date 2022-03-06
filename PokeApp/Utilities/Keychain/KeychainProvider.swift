//
//  KeychainProvider.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 16/08/21.
//

import Foundation
import KeychainAccess

struct KeychainProvider: KeychainProviderProtocol {
    private static let keychain = Keychain(service: KeychainKey.applicationId.rawValue)
    
    // MARK: - ID Token
    
    static func getIdToken() -> String {
        return keychain[KeychainKey.idToken.rawValue] ?? ""
    }
    
    static func setIdToken(idToken: String) {
        keychain[KeychainKey.idToken.rawValue] = idToken
    }
    
    static func removeIdToken() {
        keychain[KeychainKey.idToken.rawValue] = nil
    }
    
    // MARK: - Refresh Token
    
    static func getRefreshToken() -> String {
        return keychain[KeychainKey.refreshToken.rawValue] ?? ""
    }
    
    static func setRefreshToken(refreshToken: String) {
        keychain[KeychainKey.refreshToken.rawValue] = refreshToken
    }
    
    static func removeRefreshToken() {
        keychain[KeychainKey.refreshToken.rawValue] = nil
    }
}
