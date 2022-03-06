//
//  Pokemon.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 21/08/21.
//

import UIKit

struct Pokemon: Decodable {
    let number: String
    let name: String
    let species: String
    let types: [PokemonType]
    let weight: String
    let sprite: String
    let description: String
    let gen: Int
    
    enum CodingKeys: String, CodingKey {
        case number, name, species, types, weight, sprite, description, gen
    }
    
    var xp: Int = 0
    var spriteBackgroundColor: String = UIColor.systemYellow.hex()
    var spritePrimaryColor: String = UIColor.systemRed.hex()
    var spriteSecondaryColor: String = UIColor.systemBlue.hex()
    var spriteDetailColor: String = UIColor.systemGreen.hex()
    
    var hasGigaPower: Bool = false
    
    mutating func setOptionalPropertiesFromFirestore(with firestorePokemon: FirestorePokemon) {
        xp = firestorePokemon.xp
        spriteBackgroundColor = firestorePokemon.spriteBackgroundColor
        spritePrimaryColor = firestorePokemon.spritePrimaryColor
        spriteSecondaryColor = firestorePokemon.spriteSecondaryColor
        spriteDetailColor = firestorePokemon.spriteDetailColor
    }
    
    init(firestorePokemon: FirestorePokemon, isAddedToTeam: Bool = false) {
        self.number = firestorePokemon.number
        self.name = firestorePokemon.name
        self.species = firestorePokemon.species
        self.types = []
        self.weight = ""
        self.sprite = firestorePokemon.sprite
        self.description = ""
        self.gen = 0
        self.hasGigaPower = firestorePokemon.hasGigaPower
        self.xp = firestorePokemon.xp
        self.spriteBackgroundColor = firestorePokemon.spriteBackgroundColor
        self.spritePrimaryColor = firestorePokemon.spritePrimaryColor
        self.spriteSecondaryColor = firestorePokemon.spriteSecondaryColor
        self.spriteDetailColor = firestorePokemon.spriteDetailColor
    }
}
