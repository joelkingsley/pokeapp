//
//  RefreshTokenResponse.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 16/08/21.
//

import Foundation

struct RefreshTokenResponse: Decodable {
    let expiresIn: String
    let tokenType: String
    let refreshToken: String
    let idToken: String
    let userId: String
    let projectId: String
    
    enum CodingKeys: String, CodingKey {
        case expiresIn = "expires_in", tokenType = "token_type", refreshToken = "refresh_token", idToken = "id_token", userId = "user_id", projectId = "project_id"
    }
}
