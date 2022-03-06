//
//  AuthenticationRepository.swift
//  PokeApp
//
//  Created by Joel Kingsley on 24/09/21.
//

import Foundation
import Combine

protocol AuthenticationRepository {
    func signUpWithEmailAndPassword(email: String, password: String, displayName: String) -> AnyPublisher<User, Error>
    func signInWithEmailAndPassword(email: String, password: String) -> AnyPublisher<User, Error>
    func getUserDataWithIdToken() -> AnyPublisher<User, Error>
    func exchangeRefreshTokenForIdToken() -> AnyPublisher<RefreshTokenResponse, Error>
}
