//
//  FirestoreDocumentProtocol.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 26/08/21.
//

import Foundation

protocol FirestoreDocumentProtocol: Codable {
    var documentName: String? { get }
    var documentCreateTime: String? { get }
    var documentUpdateTime: String? { get }
    
    func asDictionary() -> [String: Any]
}
