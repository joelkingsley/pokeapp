//
//  HttpProviderProtocol.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 14/08/21.
//

import Foundation
import Combine

protocol HttpProviderProtocol {
    static func sendRequest(to url: String, httpMethod: HttpRequestMethod, contentType: ContentType, queryItems: [URLQueryItem]?, body: [String: Any]?, receiveOnThread: DispatchQueue) -> AnyPublisher<Data, Error>
    static func sendRequest(to url: String, httpMethod: HttpRequestMethod, contentType: ContentType?, queryItems: [URLQueryItem]?, body: [String: Any], completion: @escaping(Result<Data, Error>) -> Void)
}
