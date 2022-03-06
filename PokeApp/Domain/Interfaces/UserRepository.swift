//
//  UserRepository.swift
//  PokeApp
//
//  Created by Joel Kingsley on 24/09/21.
//

import Foundation
import Combine

protocol UserRepository {
    func createUser(user: User) -> AnyPublisher<User, Error>
    func getUserData(uid: String) -> AnyPublisher<User, Error>
    static func updateUserData(user: User) -> AnyPublisher<FirestoreUser, Error>
}
