//
//  PokemonRepository.swift
//  PokeApp
//
//  Created by Joel Kingsley on 24/09/21.
//

import Foundation
import Combine

protocol PokemonRepository {
    static func createNewPokemon(pokemon: Pokemon, completion: @escaping(Error?) -> Void)
    static func updatePokemonDetails(pokemon: FirestorePokemon, completion: @escaping(Bool) -> Void)
    static func getPokemon(number: String) -> AnyPublisher<FirestorePokemon, Error>
    static func getAllPokemons(pageSize: Int?, completion: @escaping(Result<FirestoreDocumentList<FirestorePokemon>, Error>) -> Void)
    static func getTeamsThatHaveThisPokemon(_ pokemon: FirestorePokemon) -> AnyPublisher<[String], Error>
}
