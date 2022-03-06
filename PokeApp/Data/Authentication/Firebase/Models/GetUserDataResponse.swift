//
//  GetUserDataResponse.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 16/08/21.
//

import Foundation

struct GetUserDataResponse: Decodable {
    let users: [UserObject]
    
    struct UserObject: Decodable {
        let localId: String
        let email: String
        let displayName: String
        let photoUrl: String?
        let passwordHash: String?
        let emailVerified: Bool?
        let passwordUpdatedAt: Int?
        let providerUserInfo: [ProviderUserInfoObject]?
        let validSince: String?
        let lastLoginAt: String?
        let createdAt: String?
        let lastRefreshAt: String?
        
        struct ProviderUserInfoObject: Decodable {
            let providerId: String
            let federatedId: String
            let email: String
            let rawId: String
        }
    }
}
