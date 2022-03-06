//
//  LoginUseCase.swift
//  PokeApp
//
//  Created by Joel Kingsley on 27/09/21.
//

import Foundation
import Combine

protocol LoginUseCase {
    func execute(email: String, password: String) -> AnyPublisher<User, Error>
}

class LoginUseCaseImpl: LoginUseCase {
    let authenticationRepository: AuthenticationRepository
    let userRepository: UserRepository

    init(authenticationRepository: AuthenticationRepository, userRepository: UserRepository) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
    }
}

extension LoginUseCaseImpl {
    func execute(email: String, password: String) -> AnyPublisher<User, Error> {
        return authenticationRepository.signInWithEmailAndPassword(email: email, password: password)
            .flatMap { user in
                return self.userRepository.getUserData(uid: user.uid)
            }.eraseToAnyPublisher()
    }
}
