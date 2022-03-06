//
//  CheckIfAuthenticatedUseCase.swift
//  PokeApp
//
//  Created by Joel Kingsley on 27/09/21.
//

import Foundation
import Combine

protocol CheckIfAuthenticatedUseCase {
    func execute() -> AnyPublisher<User, Error>
}

class CheckIfAuthenticatedUseCaseImpl: CheckIfAuthenticatedUseCase {
    let authenticationRepository: AuthenticationRepository
    let userRepository: UserRepository

    init(authenticationRepository: AuthenticationRepository, userRepository: UserRepository) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
    }
}

extension CheckIfAuthenticatedUseCaseImpl {
    func execute() -> AnyPublisher<User, Error> {
        return Just(KeychainProvider.getIdToken())
            .flatMap({ tokenId -> AnyPublisher<String, Error> in
                if tokenId.isEmpty {
                    print("DEBUG: tokenId is empty")
                    return Fail(error: GenericError()).eraseToAnyPublisher()
                } else {
                    print("DEBUG: tokenId is not empty")
                    return Just(tokenId).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
            .flatMap { _ in
                return self.authenticationRepository.getUserDataWithIdToken()
                    .flatMap { user -> AnyPublisher<User, Error> in
                        return self.userRepository.getUserData(uid: user.uid)
                    }
            }.eraseToAnyPublisher()
    }
}
