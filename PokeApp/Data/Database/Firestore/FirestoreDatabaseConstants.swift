//
//  FirestoreDatabaseConstants.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 17/08/21.
//

import Foundation

struct FirestoreDatabaseConstants {
    
    // MARK: - Private Constants
    
    private static let SERVICE_ENDPOINT = "https://firestore.googleapis.com/v1"
    private static let PROJECT_ID = "pokemon-dictionary-a2z"
    private static let DATABASE_ID = "(default)"
    
    // MARK: - Global Constants
    
    static let DEFAULT_PAGE_SIZE = 150
    
    // MARK: - Endpoints
    
    static let DOCUMENTS_BASE_ENDPOINT = "\(SERVICE_ENDPOINT)/projects/\(PROJECT_ID)/databases/\(DATABASE_ID)/documents"
    static let DOCUMENTS_PROJECTS_ENDPOINT = "projects/\(PROJECT_ID)/databases/\(DATABASE_ID)/documents"
    
    // MARK: - Collections
    
    static let COLLECTION_USERS = "users"
    static let COLLECTION_POKEMONS = "pokemons"
    static let COLLECTION_TEAMS = "teams"
    static let COLLECTION_POKEMONS_IN_TEAM = "pokemons-in-team"
    static let COLLECTION_TEAMS_THAT_HAVE_THIS_POKEMON = "teams-that-have-this-pokemon"
    
}
