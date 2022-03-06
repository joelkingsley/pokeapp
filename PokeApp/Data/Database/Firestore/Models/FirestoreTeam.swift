//
//  FirestoreTeam.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 12/09/21.
//

import Foundation

struct FirestoreTeam: FirestoreDocumentProtocol {
    
    let documentName: String?
    let documentCreateTime: String?
    let documentUpdateTime: String?
    
    var teamId: String? {
        guard let documentName = documentName else { return nil }
        guard let teamId = documentName.split(separator: "/").last else { return nil }
        return String(teamId)
    }
    
    let name: String
    let profileImageUrl: String
    var totalXp: Int
    let numberOfPokemonsWithGigaPower: Int
    
    enum FieldsCodingKeys: String, CodingKey {
        case name, profileImageUrl, totalXp, numberOfPokemonsWithGigaPower
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DocumentCodingKeys.self)

        documentName = try container.decode(String.self, forKey: .name)
        documentCreateTime = try container.decode(String.self, forKey: .createTime)
        documentUpdateTime = try container.decode(String.self, forKey: .updateTime)

        let fields = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)

        let teamNameField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .name)
        self.name = try teamNameField.decode(String.self, forKey: .stringValue)

        let profileImageUrlField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .profileImageUrl)
        self.profileImageUrl = try profileImageUrlField.decode(String.self, forKey: .stringValue)
        
        let totalXpField = try fields.nestedContainer(keyedBy: IntValueCodingKeys.self, forKey: .totalXp)
        self.totalXp = Int(try totalXpField.decode(String.self, forKey: .integerValue)) ?? 0
        
        let numberOfPokemonsWithGigaPowerField = try fields.nestedContainer(keyedBy: IntValueCodingKeys.self, forKey: .numberOfPokemonsWithGigaPower)
        self.numberOfPokemonsWithGigaPower = Int(try numberOfPokemonsWithGigaPowerField.decode(String.self, forKey: .integerValue)) ?? 0
    }
    
    init(name: String, profileImageUrl: String, totalXp: Int, numberOfPokemonsWithGigaPower: Int) {
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.totalXp = totalXp
        self.numberOfPokemonsWithGigaPower = numberOfPokemonsWithGigaPower

        documentName = nil
        documentCreateTime = nil
        documentUpdateTime = nil
    }
    
    func asDictionary() -> [String: Any] {
        [
            DocumentCodingKeys.fields.stringValue: [
                FieldsCodingKeys.name.stringValue: [StringValueCodingKeys.stringValue.stringValue: name],
                FieldsCodingKeys.profileImageUrl.stringValue: [StringValueCodingKeys.stringValue.stringValue: profileImageUrl],
                FieldsCodingKeys.totalXp.stringValue: [IntValueCodingKeys.integerValue.stringValue: totalXp],
                FieldsCodingKeys.numberOfPokemonsWithGigaPower.stringValue: [IntValueCodingKeys.integerValue.stringValue: numberOfPokemonsWithGigaPower]
            ]
        ]
    }
}
