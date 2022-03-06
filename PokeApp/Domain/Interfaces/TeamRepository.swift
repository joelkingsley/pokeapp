//
//  TeamRepository.swift
//  PokeApp
//
//  Created by Joel Kingsley on 24/09/21.
//

import Foundation
import Combine

protocol TeamRepository {
    static func createTeam(_ team: FirestoreTeam, for userId: String, with pokemons: [FirestorePokemon]) -> AnyPublisher<FirestoreCommitResponse, Error>
    static func getAllTeams(of user: User , pageSize: Int?, completion: @escaping(Result<FirestoreDocumentList<FirestoreTeam>, Error>) -> Void)
    static func updateTeamDetails(team: FirestoreTeam, user: FirestoreUser) ->  AnyPublisher<FirestoreTeam, Error>
    static func addPokemonsToTeam(pokemons: [FirestorePokemon], team: FirestoreTeam, of user: User) -> AnyPublisher<FirestoreCommitResponse, Error>
}
