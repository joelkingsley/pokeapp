//
//  FirebaseAuthenticationProvider.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 14/08/21.
//

import Foundation
import KeychainAccess
import Combine

struct FirebaseAuthenticationProvider: AuthenticationRepository {
    
    private static var cancellables = Set<AnyCancellable>()
    
    func signUpWithEmailAndPassword(email: String, password: String, displayName: String) -> AnyPublisher<User, Error> {
        let url = FirebaseAuthenticationConstants.IDENTITY_TOOLKIT_ENDPOINT + FirebaseAuthenticationConstants.SIGN_UP_ENDPOINT
        let queryItems = [URLQueryItem(name: "key", value: FirebaseAuthenticationConstants.WEB_API_KEY)]
        let body: [String: AnyHashable] = [
            "email": email,
            "password": password,
            "displayName": displayName,
            "returnSecureToken": true,
        ]
        
        return HttpProvider.sendRequest(to: url, httpMethod: .post, queryItems: queryItems, body: body)
            .decode(type: RegistrationResponse.self, decoder: JSONDecoder())
            .map({ response -> User in
                KeychainProvider.setIdToken(idToken: response.idToken)
                KeychainProvider.setRefreshToken(refreshToken: response.refreshToken)
                return User(response: response)
            })
            .mapError({
                print("DEBUG: Got error while decoding in signUpWithEmailAndPassword: \($0.localizedDescription)")
                return $0
            })
            .eraseToAnyPublisher()

    }
    
    func signInWithEmailAndPassword(email: String, password: String) -> AnyPublisher<User, Error> {
        let url = FirebaseAuthenticationConstants.IDENTITY_TOOLKIT_ENDPOINT + FirebaseAuthenticationConstants.SIGN_IN_ENDPOINT
        let queryItems = [URLQueryItem(name: "key", value: FirebaseAuthenticationConstants.WEB_API_KEY)]
        let body: [String: AnyHashable] = [
            "email": email,
            "password": password,
            "returnSecureToken": true,
        ]
        
        return HttpProvider.sendRequest(to: url, httpMethod: .post, queryItems: queryItems, body: body)
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .map({ response -> User in
                print("DEBUG: signInWithEmailAndPassword completed")
                KeychainProvider.setIdToken(idToken: response.idToken)
                KeychainProvider.setRefreshToken(refreshToken: response.refreshToken)
                return User(response: response)
            })
            .mapError({
                print("DEBUG: Got error while decoding in signInWithEmailAndPassword: \($0.localizedDescription)")
                return $0
            })
            .eraseToAnyPublisher()
    }
    
    func getUserDataWithIdToken() -> AnyPublisher<User, Error> {
        let url = FirebaseAuthenticationConstants.IDENTITY_TOOLKIT_ENDPOINT + FirebaseAuthenticationConstants.GET_USER_DATA_ENDPOINT
        let queryItems = [URLQueryItem(name: "key", value: FirebaseAuthenticationConstants.WEB_API_KEY)]
        let idToken = KeychainProvider.getIdToken()
        let body: [String: AnyHashable] = [
            "idToken": idToken
        ]
        
        return HttpProvider.sendRequest(to: url, httpMethod: .post, queryItems: queryItems, body: body)
            .decode(type: GetUserDataResponse.self, decoder: JSONDecoder())
            .map({ response in
                return User(response: response)
            })
            .mapError({
                print("DEBUG: Got error while decoding in getUserDataWithIdToken: \($0.localizedDescription)")
                return $0
            })
            .eraseToAnyPublisher()
    }
    
    func exchangeRefreshTokenForIdToken() -> AnyPublisher<RefreshTokenResponse, Error> {
        let url = FirebaseAuthenticationConstants.SECURE_TOKEN_ENDPOINT + FirebaseAuthenticationConstants.REFRESH_TOKEN_ENDPOINT
        let queryItems = [URLQueryItem(name: "key", value: FirebaseAuthenticationConstants.WEB_API_KEY)]
        let refreshToken = KeychainProvider.getRefreshToken()
        let body: [String: AnyHashable] = [
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]
        
        return HttpProvider.sendRequest(to: url, httpMethod: .post, contentType: .formUrlEncoded, queryItems: queryItems, body: body)
            .decode(type: RefreshTokenResponse.self, decoder: JSONDecoder())
            .mapError({
                print("DEBUG: Got error while decoding in exchangeRefreshTokenForIdToken: \($0.localizedDescription)")
                return $0
            })
            .eraseToAnyPublisher()
    }
}
