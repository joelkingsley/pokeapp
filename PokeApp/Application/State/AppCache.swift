//
//  AppCache.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 14/09/21.
//

import Foundation

final class AppCache {
    
    static let shared = AppCache()
    
    private init() {
        self.allPokemonsFromPokedexAPI = nil
        self.allPokemonsFromFirestore = nil
    }
    
    var allPokemonsFromPokedexAPI: [Pokemon]?
    var allPokemonsFromFirestore: FirestoreDocumentList<FirestorePokemon>?
}
