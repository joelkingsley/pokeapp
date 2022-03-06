//
//  FirestoreProvider.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 17/08/21.
//

import Foundation
import Combine

struct FirestoreDatabaseProvider {
    
    private static var cancellables = Set<AnyCancellable>()
    
}

// MARK: - UserRepository

extension FirestoreDatabaseProvider: UserRepository {
    func createUser(user: User) -> AnyPublisher<User, Error> {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)"
        let queryItems = [
            URLQueryItem(name: "documentId", value: user.uid)
        ]
        let body: [String: Any] = FirestoreUser(user: user).asDictionary()
        
        return HttpProvider.sendRequest(to: url, httpMethod: .post, queryItems: queryItems, body: body)
            .decode(type: FirestoreUser.self, decoder: JSONDecoder())
            .map({ response -> User in
                return User(firestoreUser: response)
            })
            .mapError({
                print("DEBUG: Got error while decoding: \($0.localizedDescription)")
                return $0
            })
            .eraseToAnyPublisher()
    }
    
    func getUserData(uid: String) -> AnyPublisher<User, Error> {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)/\(uid)"
        
        return HttpProvider.sendRequest(to: url, httpMethod: .get)
            .decode(type: FirestoreUser.self, decoder: JSONDecoder())
            .map({ response -> User in
                return User(firestoreUser: response)
            })
            .mapError({
                print("DEBUG: Got error while decoding in getUserData: \($0.localizedDescription)")
                return $0
            })
            .eraseToAnyPublisher()
    }
    
    static func updateUserData(user: User) -> AnyPublisher<FirestoreUser, Error> {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)/\(user.uid)"
        let body: [String: Any] = FirestoreUser(user: user).asDictionary()
        
        return HttpProvider.sendRequest(to: url, httpMethod: .patch, body: body)
            .decode(type: FirestoreUser.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK: - PokemonRepository

extension FirestoreDatabaseProvider: PokemonRepository {
    static func createNewPokemon(pokemon: Pokemon, completion: @escaping(Error?) -> Void) {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS)"
        let queryItems = [
            URLQueryItem(name: "documentId", value: pokemon.number)
        ]
        let body: [String: Any] = FirestorePokemon(pokemon: pokemon).asDictionary()
        HttpProvider.sendRequest(to: url, httpMethod: .post, queryItems: queryItems, body: body) { result in
            switch result {
            case .success(let data):
                do {
                    let _ = try JSONDecoder().decode(FirestorePokemon.self, from: data)
                    completion(nil)
                } catch {
                    print("DEBUG: JSON error occurred while updating pokemon \(pokemon.number) - \(error)")
                    completion(error)
                }
            case .failure(let error):
                print("DEBUG: Request error occurred while updating pokemon \(pokemon.number) - \(error)")
                completion(error)
            }
        }
    }
    
    static func updatePokemonDetails(pokemon: FirestorePokemon, completion: @escaping(Bool) -> Void) {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS)/\(pokemon.number)"
        let body: [String: Any] = pokemon.asDictionary()
        
        HttpProvider.sendRequest(to: url, httpMethod: .patch, body: body)
            .decode(type: FirestorePokemon.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sink { completed in
                if case .failure(let error) = completed {
                    print("DEBUG: Error occurred while updating pokemon \(pokemon.number) - \(error.localizedDescription)")
                    completion(false)
                }
            } receiveValue: { response in
                print("DEBUG: updatePokemonDetails completed")
                completion(true)
            }.store(in: &cancellables)
        
    }
    
    static func getPokemon(number: String) -> AnyPublisher<FirestorePokemon, Error> {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS)/\(number)"
        
        return HttpProvider.sendRequest(to: url, httpMethod: .get)
            .decode(type: FirestorePokemon.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    static func getAllPokemons(pageSize: Int? = FirestoreDatabaseConstants.DEFAULT_PAGE_SIZE, completion: @escaping(Result<FirestoreDocumentList<FirestorePokemon>, Error>) -> Void) {
        if let cachedPokemons = AppCache.shared.allPokemonsFromFirestore {
            completion(.success(cachedPokemons))
            return
        }
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS)/"
        var queryItems = [URLQueryItem]()
        if let pageSize = pageSize {
            queryItems.append(URLQueryItem(name: "pageSize", value: String(pageSize)))
        }
        
        HttpProvider.sendRequest(to: url, httpMethod: .get, queryItems: queryItems)
            .decode(type: FirestoreDocumentList<FirestorePokemon>.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sink { completed in
                if case .failure(let error) = completed {
                    print("DEBUG: Error occurred while getting additional details of pokemons - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            } receiveValue: { response in
                print("DEBUG: getAllPokemons completed")
                var pokemons = response
                pokemons.list.sort { a, b in
                    guard let num1 = Int(a.number) else { return true }
                    guard let num2 = Int(b.number) else { return true }
                    return num1 < num2
                }
                if pageSize == nil {
                    let indicesOfPokemonsWithGigaPower = Int.getUniqueRandomNumbers(min: 0, max: pokemons.list.count-1, count: 20)
                    indicesOfPokemonsWithGigaPower.forEach { index in
                        pokemons.list[index].hasGigaPower = true
                    }
                    AppCache.shared.allPokemonsFromFirestore = pokemons
                }
                completion(.success(pokemons))
            }.store(in: &cancellables)
    }
}

// MARK: - TeamRepository

extension FirestoreDatabaseProvider: TeamRepository {
    static func createTeam(_ team: FirestoreTeam, for userId: String, with pokemons: [FirestorePokemon]) -> AnyPublisher<FirestoreCommitResponse, Error> {
        
        let addTeamRequestUrl = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)/\(userId)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS)"
        let addTeamRequestBody: [String: Any] = team.asDictionary()

        let addTeamRequest = HttpProvider.sendRequest(to: addTeamRequestUrl, httpMethod: .post, body: addTeamRequestBody, receiveOnThread: .global())
            .decode(type: FirestoreTeam.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()

        return addTeamRequest
            .flatMap({ team -> AnyPublisher<FirestoreCommitResponse, Error> in
                let addPokemonsToTeamRequestUrl = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT):commit"
                var addPokemonsToTeamRequestBody: [String: [Any]] = ["writes": []]
                
                pokemons.forEach { pokemon in
                    let teamId = team.teamId!
                    
                    var pokemonDictionary = pokemon.asDictionary()
                    pokemonDictionary["name"] = "\(FirestoreDatabaseConstants.DOCUMENTS_PROJECTS_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)/\(userId)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS)/\(teamId)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS_IN_TEAM)/\(pokemon.number)"
                    
                    let addPokemonOperation = [
                        "update": pokemonDictionary
                    ]
                    
                    addPokemonsToTeamRequestBody["writes"]?.append(addPokemonOperation)
                    
                    let teamsListInPokemonDictionary = [
                        DocumentCodingKeys.fields.stringValue: [:],
                        DocumentCodingKeys.name.stringValue: "\(FirestoreDatabaseConstants.DOCUMENTS_PROJECTS_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS)/\(pokemon.number)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS_THAT_HAVE_THIS_POKEMON)/\(teamId)"
                    ] as [String : Any]
                    
                    let updateTeamsListInPokemonOperation = [
                        "update": teamsListInPokemonDictionary
                    ]
                    
                    print("DEBUG: JSON = \(updateTeamsListInPokemonOperation)")
                    addPokemonsToTeamRequestBody["writes"]?.append(updateTeamsListInPokemonOperation)
                }
                print("Request body before sending: \(addPokemonsToTeamRequestBody)")
                
                return HttpProvider.sendRequest(to: addPokemonsToTeamRequestUrl, httpMethod: .post, body: addPokemonsToTeamRequestBody)
                    .decode(type: FirestoreCommitResponse.self, decoder: JSONDecoder())
                    .mapError({
                        print("DEBUG: Error in add pokemons to team request - \($0)")
                        return $0
                    })
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    static func getAllTeams(of user: User , pageSize: Int? = FirestoreDatabaseConstants.DEFAULT_PAGE_SIZE, completion: @escaping(Result<FirestoreDocumentList<FirestoreTeam>, Error>) -> Void) {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)/\(user.uid)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS)"
        var queryItems = [URLQueryItem]()
        if let pageSize = pageSize {
            queryItems.append(URLQueryItem(name: "pageSize", value: String(pageSize)))
        }
        
        HttpProvider.sendRequest(to: url, httpMethod: .get, queryItems: queryItems)
            .decode(type: FirestoreDocumentList<FirestoreTeam>.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .sink { completed in
                if case .failure(let error) = completed {
                    print("DEBUG: Error occurred while getting all teams - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            } receiveValue: { response in
                print("DEBUG: Completed fetching all teams")
                completion(.success(response))
            }.store(in: &cancellables)
    }
    
    static func updateTeamDetails(team: FirestoreTeam, user: FirestoreUser) ->  AnyPublisher<FirestoreTeam, Error> {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)/\(user.uid)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS)/\(team.teamId!)"
        let body: [String: Any] = team.asDictionary()
        
        return HttpProvider.sendRequest(to: url, httpMethod: .patch, body: body)
            .decode(type: FirestoreTeam.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    static func getPokemonsinTeam(_ team: FirestoreTeam, of user: User) -> AnyPublisher<FirestoreDocumentList<FirestorePokemon>, Error> {
        let teamDocumentName = team.documentName!
        let teamId = String(teamDocumentName.split(separator: "/").last!)
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)/\(user.uid)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS)/\(teamId)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS_IN_TEAM)"
        
        return HttpProvider.sendRequest(to: url, httpMethod: .get)
            .decode(type: FirestoreDocumentList<FirestorePokemon>.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    static func addPokemonsToTeam(pokemons: [FirestorePokemon], team: FirestoreTeam, of user: User) -> AnyPublisher<FirestoreCommitResponse, Error> {
        let teamId = team.teamId!
        
        let addPokemonsToTeamRequestUrl = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT):commit"
        var addPokemonsToTeamRequestBody: [String: [Any]] = ["writes": []]
        
        pokemons.forEach { pokemon in
            var addPokemonDictionary = pokemon.asDictionary()
            addPokemonDictionary["name"] = "\(FirestoreDatabaseConstants.DOCUMENTS_PROJECTS_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_USERS)/\(user.uid)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS)/\(teamId)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS_IN_TEAM)/\(pokemon.number)"
            
            let addPokemonOperation = [
                "update": addPokemonDictionary
            ]
            
            addPokemonsToTeamRequestBody["writes"]?.append(addPokemonOperation)
            
            let teamsListInPokemonDictionary = [
                DocumentCodingKeys.fields.stringValue: [:],
                DocumentCodingKeys.name.stringValue: "\(FirestoreDatabaseConstants.DOCUMENTS_PROJECTS_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS)/\(pokemon.number)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS_THAT_HAVE_THIS_POKEMON)/\(teamId)"
            ] as [String : Any]
            
            let updateTeamsListInPokemonOperation = [
                "update": teamsListInPokemonDictionary
            ]
            
            print("DEBUG: JSON = \(updateTeamsListInPokemonOperation)")
            
            addPokemonsToTeamRequestBody["writes"]?.append(updateTeamsListInPokemonOperation)
        }
        
        return HttpProvider.sendRequest(to: addPokemonsToTeamRequestUrl, httpMethod: .post, body: addPokemonsToTeamRequestBody)
            .decode(type: FirestoreCommitResponse.self, decoder: JSONDecoder())
            .mapError({
                print("DEBUG: Error in add pokemons to team request - \($0)")
                return $0
            })
            .eraseToAnyPublisher()
    }
    
    static func getTeamsThatHaveThisPokemon(_ pokemon: FirestorePokemon) -> AnyPublisher<[String], Error> {
        let url = "\(FirestoreDatabaseConstants.DOCUMENTS_BASE_ENDPOINT)/\(FirestoreDatabaseConstants.COLLECTION_POKEMONS)/\(pokemon.number)/\(FirestoreDatabaseConstants.COLLECTION_TEAMS_THAT_HAVE_THIS_POKEMON)"
        
        return HttpProvider.sendRequest(to: url, httpMethod: .get)
            .decode(type: FirestoreDocumentList<FirestoreDocument>.self, decoder: JSONDecoder())
            .map({
                $0.list.map({
                    guard let documentName = $0.documentName else { return "" }
                    return String(documentName.split(separator: "/").last ?? "")
                })
            })
            .eraseToAnyPublisher()
    }
}
