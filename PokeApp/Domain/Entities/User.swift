//
//  User.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 16/08/21.
//

import Foundation

struct User: Codable {
    let uid: String
    let email: String
    let displayName: String
    var xp: Int
    
    init(response: GetUserDataResponse) {
        uid = response.users[0].localId
        email = response.users[0].email
        displayName = response.users[0].displayName
        xp = -1
    }
    
    init(response: RegistrationResponse) {
        uid = response.localId
        email = response.email
        displayName = response.displayName
        xp = 100
    }
    
    init(response: LoginResponse) {
        uid = response.localId
        email = response.email
        displayName = response.displayName
        xp = -1
    }
    
    init(firestoreUser: FirestoreUser) {
        uid = firestoreUser.uid
        email = firestoreUser.email
        displayName = firestoreUser.displayName
        xp = firestoreUser.xp
    }
}
