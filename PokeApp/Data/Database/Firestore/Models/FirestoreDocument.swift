//
//  FirestoreDocument.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 19/09/21.
//

import Foundation

struct FirestoreDocument: FirestoreDocumentProtocol {
    
    var documentName: String?
    var documentCreateTime: String?
    var documentUpdateTime: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DocumentCodingKeys.self)

        documentName = try container.decode(String.self, forKey: .name)
        documentCreateTime = try container.decode(String.self, forKey: .createTime)
        documentUpdateTime = try container.decode(String.self, forKey: .updateTime)
    }
    
    func asDictionary() -> [String : Any] {
        return [DocumentCodingKeys.fields.stringValue: [:]]
    }
}
