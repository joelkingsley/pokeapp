//
//  PokemonListItemViewModel.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 07/09/21.
//

import UIKit

struct PokemonListItemViewModel {
    var pokemon: FirestorePokemon
    
    var spriteImageUrl: URL? {
        return URL(string: pokemon.sprite)
    }
    
    var nationalNumber: String {
        return "#\(pokemon.number)"
    }
    
    var pokemonName: String {
        return pokemon.name
    }
    
    var speciesName: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Species: ", attributes: [.font: UIFont(name: "Avenir", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)])
        attributedText.append(NSAttributedString(string: pokemon.species, attributes: [.font: UIFont(name: "Futura Medium", size: 14.0) ?? UIFont.boldSystemFont(ofSize: 14.0)]))
        return attributedText
    }
    
    var xp: String {
        let xpValue = pokemon.xp
        return "\(xpValue) XP"
    }
    
    var isAddedToTeam: Bool = false
    
    var isDisabled: Bool = false
    
    init(pokemon: FirestorePokemon, isDisabled: Bool) {
        self.pokemon = pokemon
        self.isDisabled = isDisabled
    }
}
