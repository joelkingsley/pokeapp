//
//  PokedexAPIProvider.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 21/08/21.
//

import Foundation
import Combine

struct PokedexAPIProvider: PokedexRepository {
    
    private static var cancellables = Set<AnyCancellable>()
    
    static func fetchPokemon(number: String) -> AnyPublisher<Pokemon, Error> {
        return HttpProvider.sendRequest(to: "\(PokedexAPIConstants.SERVICE_ENDPOINT)/\(number)", httpMethod: .get)
            .decode(type: [Pokemon].self, decoder: JSONDecoder())
            .compactMap({ $0.first })
            .mapError({
                print("Error while fetching pokemon \(number) - \($0.localizedDescription)")
                return $0
            })
            .eraseToAnyPublisher()
    }
    
    static func fetchPokemons(from startNumber: Int, to endNumber: Int, completion: @escaping([Pokemon]) -> Void) {
        if let cachedPokemons = AppCache.shared.allPokemonsFromPokedexAPI {
            completion(cachedPokemons)
            return
        }
        Just(startNumber...endNumber)
            .setFailureType(to: Error.self)
            .flatMap { ids -> Publishers.MergeMany<AnyPublisher<Pokemon, Error>> in
                let requests = ids.map { pokemonId -> AnyPublisher<Pokemon, Error> in
                    return HttpProvider.sendRequest(to: "\(PokedexAPIConstants.SERVICE_ENDPOINT)/\(pokemonId)", httpMethod: .get, receiveOnThread: .global())
                        .decode(type: [Pokemon].self, decoder: JSONDecoder())
                        .compactMap({ $0.first })
                        .mapError({
                            print("\($0.localizedDescription) - \(pokemonId)")
                            return $0
                        })
                        .eraseToAnyPublisher()
                }
                return Publishers.MergeMany(requests)
            }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { (completed) in
                if case .failure(let error) = completed {
                    print("DEBUG: Got error: \(error.localizedDescription)")
                    completion([])
                }
            } receiveValue: { (list) in
                print("DEBUG: fetchPokemons completed")
                var pokemons = list
                pokemons.sort { a, b in
                    guard let num1 = Int(a.number) else { return true }
                    guard let num2 = Int(b.number) else { return true }
                    return num1 < num2
                }
                AppCache.shared.allPokemonsFromPokedexAPI = pokemons
                completion(pokemons)
            }.store(in: &cancellables)
    }
    
}
