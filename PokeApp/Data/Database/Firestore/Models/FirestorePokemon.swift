//
//  FirestorePokemon.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 23/08/21.
//

import UIKit

struct FirestorePokemon: FirestoreDocumentProtocol {
    
    let documentName: String?
    let documentCreateTime: String?
    let documentUpdateTime: String?
    
    let number: String
    let name: String
    let species: String
    let sprite: String
    let xp: Int
    
    var spriteBackgroundColor: String
    var spritePrimaryColor: String
    var spriteSecondaryColor: String
    var spriteDetailColor: String
    
    var hasGigaPower: Bool
    
    enum FieldsCodingKeys: String, CodingKey {
        case number, name, species, sprite, xp, hasGigaPower, spriteBackgroundColor, spritePrimaryColor, spriteSecondaryColor, spriteDetailColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DocumentCodingKeys.self)

        documentName = try container.decode(String.self, forKey: .name)
        documentCreateTime = try container.decode(String.self, forKey: .createTime)
        documentUpdateTime = try container.decode(String.self, forKey: .updateTime)

        let fields = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)

        let numberField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .number)
        number = try numberField.decode(String.self, forKey: .stringValue)

        let nameField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .name)
        name = try nameField.decode(String.self, forKey: .stringValue)
        
        let speciesField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .species)
        species = try speciesField.decode(String.self, forKey: .stringValue)
        
        let spriteField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .sprite)
        sprite = try spriteField.decode(String.self, forKey: .stringValue)
        
        let xpField = try fields.nestedContainer(keyedBy: IntValueCodingKeys.self, forKey: .xp)
        xp = Int(try xpField.decode(String.self, forKey: .integerValue)) ?? 0
        
        if fields.contains(.hasGigaPower) {
            let hasGigaPowerField = try fields.nestedContainer(keyedBy: BoolValueCodingKeys.self, forKey: .hasGigaPower)
            hasGigaPower = try hasGigaPowerField.decode(Bool.self, forKey: .booleanValue)
        } else {
            hasGigaPower = false
        }
        
        if fields.contains(.spriteBackgroundColor) {
            let spriteBackgroundColorField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .spriteBackgroundColor)
            spriteBackgroundColor = try spriteBackgroundColorField.decode(String.self, forKey: .stringValue)
        } else {
            spriteBackgroundColor = UIColor.systemYellow.hex()
        }
        
        if fields.contains(.spritePrimaryColor) {
            let spritePrimaryColorField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .spritePrimaryColor)
            spritePrimaryColor = try spritePrimaryColorField.decode(String.self, forKey: .stringValue)
        } else {
            spritePrimaryColor = UIColor.systemRed.hex()
        }
        
        if fields.contains(.spriteSecondaryColor) {
            let spriteSecondaryColorField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .spriteSecondaryColor)
            spriteSecondaryColor = try spriteSecondaryColorField.decode(String.self, forKey: .stringValue)
        } else {
            spriteSecondaryColor = UIColor.systemBlue.hex()
        }
        
        if fields.contains(.spriteDetailColor) {
            let spriteDetailColorField = try fields.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .spriteDetailColor)
            spriteDetailColor = try spriteDetailColorField.decode(String.self, forKey: .stringValue)
        } else {
            spriteDetailColor = UIColor.systemGreen.hex()
        }
    }
    
    init(pokemon: Pokemon) {
        number = pokemon.number
        name = pokemon.name
        species = pokemon.species
        sprite = pokemon.sprite
        xp = pokemon.xp
        hasGigaPower = pokemon.hasGigaPower

        documentName = nil
        documentCreateTime = nil
        documentUpdateTime = nil
        
        spriteBackgroundColor = UIColor.systemYellow.hex()
        spritePrimaryColor = UIColor.systemRed.hex()
        spriteSecondaryColor = UIColor.systemBlue.hex()
        spriteDetailColor = UIColor.systemGreen.hex()
    }
    
    func asDictionary() -> [String: Any] {
        [
            DocumentCodingKeys.fields.stringValue: [
                FieldsCodingKeys.number.stringValue: [StringValueCodingKeys.stringValue.stringValue: number],
                FieldsCodingKeys.name.stringValue: [StringValueCodingKeys.stringValue.stringValue: name],
                FieldsCodingKeys.species.stringValue: [StringValueCodingKeys.stringValue.stringValue: species],
                FieldsCodingKeys.sprite.stringValue: [StringValueCodingKeys.stringValue.stringValue: sprite],
                FieldsCodingKeys.xp.stringValue: [IntValueCodingKeys.integerValue.stringValue: xp],
                FieldsCodingKeys.hasGigaPower.stringValue: [BoolValueCodingKeys.booleanValue.stringValue: hasGigaPower],
                FieldsCodingKeys.spriteBackgroundColor.stringValue: [StringValueCodingKeys.stringValue.stringValue: spriteBackgroundColor],
                FieldsCodingKeys.spritePrimaryColor.stringValue: [StringValueCodingKeys.stringValue.stringValue: spritePrimaryColor],
                FieldsCodingKeys.spriteSecondaryColor.stringValue: [StringValueCodingKeys.stringValue.stringValue: spriteSecondaryColor],
                FieldsCodingKeys.spriteDetailColor.stringValue: [StringValueCodingKeys.stringValue.stringValue: spriteDetailColor]
            ]
        ]
    }
}
