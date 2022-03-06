//
//  PokedexRepository.swift
//  PokeApp
//
//  Created by Joel Kingsley on 24/09/21.
//

import Foundation
import Combine

protocol PokedexRepository {
    static func fetchPokemon(number: String) -> AnyPublisher<Pokemon, Error>
    static func fetchPokemons(from startNumber: Int, to endNumber: Int, completion: @escaping([Pokemon]) -> Void)
}
