//
//  TeamListItemViewModel.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 13/09/21.
//

import UIKit

struct TeamListItemViewModel {
    var team: FirestoreTeam
    
    var profileImageUrl: URL? {
        return URL(string: team.profileImageUrl)
    }
    
    var teamName: String {
        return team.name
    }
    
    var totalXp: String {
        let xpValue = team.totalXp
        return "Total: \(xpValue) XP"
    }
    
    var numberOfPokemonsWithGigaPower: Int {
        return team.numberOfPokemonsWithGigaPower
    }
    
    var hasSelectedPokemon: Bool = false
    
    var isDisabled: Bool = false
    
    init(team: FirestoreTeam, isDisabled: Bool) {
        self.team = team
        self.isDisabled = isDisabled
    }
}
