//
//  HttpProvider.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 14/08/21.
//

import Foundation
import Combine

struct HttpProvider: HttpProviderProtocol {
    
    static func sendRequest(to url: String, httpMethod: HttpRequestMethod, contentType: ContentType = .json, queryItems: [URLQueryItem]? = nil, body: [String: Any]? = nil, receiveOnThread: DispatchQueue = .main) -> AnyPublisher<Data, Error> {
        
        guard var urlComponents = URLComponents(string: url) else { fatalError("Invalid URL") }
        urlComponents.queryItems = queryItems
        guard let finalUrl = urlComponents.url else { fatalError("Invalid URL") }
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = httpMethod.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        if let body = body {
            let requestBody: [String: Any] = body
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError({ $0 as Error })
            .map({ $0.data })
            .receive(on: receiveOnThread)
            .eraseToAnyPublisher()
    }
    
    static func sendRequest(to url: String, httpMethod: HttpRequestMethod, contentType: ContentType? = .json, queryItems: [URLQueryItem]?, body: [String: Any], completion: @escaping(Result<Data, Error>) -> Void) {
            
            guard var urlComponents = URLComponents(string: url) else { return }
            urlComponents.queryItems = queryItems
            guard let finalUrl = urlComponents.url else { return }
            
            var request = URLRequest(url: finalUrl)
            request.httpMethod = httpMethod.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = body
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
            
            let task = URLSession.shared.dataTask(with: request) { data, urlResponse, requestError in
                guard let data = data else {
                    guard let requestError = requestError else {
                        completion(.failure(NSError(domain: "Request", code: 400, userInfo: nil)))
                        return
                    }
                    completion(.failure(requestError))
                    return
                }
                completion(.success(data))
            }
            task.resume()
        }
}
