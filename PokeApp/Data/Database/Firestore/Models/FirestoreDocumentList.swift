//
//  FirestoreDocumentList.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 26/08/21.
//

import Foundation

struct FirestoreDocumentList<Element: FirestoreDocumentProtocol>: Decodable {
    var list: [Element]
    
    enum DocumentListCodingKeys: String, CodingKey {
        case documents
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DocumentListCodingKeys.self)
        list = try container.decode([Element].self, forKey: .documents)
    }
}
