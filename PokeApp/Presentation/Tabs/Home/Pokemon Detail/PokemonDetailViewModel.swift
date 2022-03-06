//
//  PokemonDetailViewModel.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 10/09/21.
//

import UIKit

struct PokemonDetailViewModel {
    var pokemon: Pokemon
    
    var spriteImageUrl: URL? {
        return URL(string: pokemon.sprite)
    }
    
    var nationalNumber: String {
        return "#\(pokemon.number)"
    }
    
    var pokemonName: String {
        return pokemon.name
    }
    
    var description: String {
        return pokemon.description
    }
    
    var speciesName: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: pokemon.species, attributes: [.font: UIFont(name: "Futura Medium Italic", size: 16) ?? UIFont.systemFont(ofSize: 16)])
        return attributedText
    }
    
    var weight: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: pokemon.weight, attributes: [.font: UIFont(name: "Futura Medium Italic", size: 16) ?? UIFont.systemFont(ofSize: 16)])
        return attributedText
    }
    
    var generation: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "Stage \(pokemon.gen)", attributes: [.font: UIFont(name: "Futura Medium Italic", size: 16) ?? UIFont.systemFont(ofSize: 16)])
        return attributedText
    }
    
    var xp: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(pokemon.xp) XP", attributes: [.font: UIFont(name: "Futura Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)])
        return attributedText
    }
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
    }
}
