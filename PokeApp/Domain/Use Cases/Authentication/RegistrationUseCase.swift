//
//  RegistrationUseCase.swift
//  PokeApp
//
//  Created by Joel Kingsley on 27/09/21.
//

import Foundation
import Combine

protocol RegistrationUseCase {
    func execute(email: String, password: String, displayName: String) -> AnyPublisher<User, Error>
}

class RegistrationUseCaseImpl: RegistrationUseCase {
    let authenticationRepository: AuthenticationRepository
    let userRepository: UserRepository

    init(authenticationRepository: AuthenticationRepository, userRepository: UserRepository) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
    }
}

extension RegistrationUseCaseImpl {
    func execute(email: String, password: String, displayName: String) -> AnyPublisher<User, Error> {
        return authenticationRepository.signUpWithEmailAndPassword(email: email, password: password, displayName: displayName)
            .flatMap { user -> AnyPublisher<User, Error> in
                return self.userRepository.createUser(user: user)
            }
            .eraseToAnyPublisher()
    }
}
