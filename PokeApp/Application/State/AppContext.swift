//
//  AppContext.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 08/09/21.
//

import Foundation

final class AppContext {
    
    static let instance = AppContext()
    
    enum State {
        case unregistered
        case loggedIn(User)
        case sessionExpired(User)
    }
    
    var state: State = .unregistered
    
    private init() { }
}
