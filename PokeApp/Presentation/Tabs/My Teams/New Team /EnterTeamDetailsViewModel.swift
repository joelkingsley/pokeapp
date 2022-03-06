//
//  EnterTeamDetailsViewModel.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 08/09/21.
//

import UIKit

struct EnterTeamDetailsViewModel {
    var teamName: String?
    
    var teamProfileImageUrl: String?
    
    var formIsValid: Bool {
        guard let name = teamName else { return false }
        
        let isNameValid = !name.isEmpty && RegexValidationProvider.validate(target: name, with: RegexPatternConstants.displayName)
        
        return isNameValid
    }
}
