//
//  FirebaseAuthenticationConstants.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 14/08/21.
//

import Foundation

struct FirebaseAuthenticationConstants {
    static let IDENTITY_TOOLKIT_ENDPOINT = "https://identitytoolkit.googleapis.com/v1/"
    static let SECURE_TOKEN_ENDPOINT = "https://securetoken.googleapis.com/v1/"
    static let WEB_API_KEY = "AIzaSyBqeqCQGNXzC9krBnK6LbLv9392nn26dXs"
    
    // MARK: - Sign Up
    static let SIGN_UP_ENDPOINT = "accounts:signUp"
    
    // MARK: - Sign In
    static let SIGN_IN_ENDPOINT = "accounts:signInWithPassword"
    
    // MARK: - Get User Data
    static let GET_USER_DATA_ENDPOINT = "accounts:lookup"
    
    // MARK: - Refresh Token
    static let REFRESH_TOKEN_ENDPOINT = "token"
}
