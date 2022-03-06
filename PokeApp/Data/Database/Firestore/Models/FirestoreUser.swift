//
//  FirestoreUser.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 18/08/21.
//

import Foundation

struct FirestoreUser: FirestoreDocumentProtocol {
    
    let documentName: String?
    let documentCreateTime: String?
    let documentUpdateTime: String?
    
    let uid: String
    let email: String
    let displayName: String
    let xp: Int
    
    enum FieldsCodingKeys: String, CodingKey {
        case uid, email, displayName, xp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DocumentCodingKeys.self)

        documentName = try container.decode(String.self, forKey: .name)
        documentCreateTime = try container.decode(String.self, forKey: .createTime)
        documentUpdateTime = try container.decode(String.self, forKey: .updateTime)

        let fields = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)

        let uidField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .uid)
        uid = try uidField.decode(String.self, forKey: .stringValue)

        let emailField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .email)
        email = try emailField.decode(String.self, forKey: .stringValue)

        let displayNameField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .displayName)
        displayName = try displayNameField.decode(String.self, forKey: .stringValue)

        let xpField = try fields.nestedContainer(keyedBy: IntValueCodingKeys.self, forKey: .xp)
        xp = Int(try xpField.decode(String.self, forKey: .integerValue)) ?? 0
    }
    
    init(user: User) {
        uid = user.uid
        email = user.email
        displayName = user.displayName
        xp = user.xp
        
        documentName = nil
        documentCreateTime = nil
        documentUpdateTime = nil
    }
    
    func asDictionary() -> [String : Any] {
        [
            "fields": [
                "uid": ["stringValue": uid],
                "email": ["stringValue": email],
                "displayName": ["stringValue": displayName],
                "xp": ["integerValue": xp]
            ]
        ]
    }
}
