//
//  BaseCoordinator.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 21/09/21.
//

import Foundation

class BaseCoordinator : Coordinator {
    var childCoordinators : [Coordinator] = []
    var isCompleted: (() -> ())?

    func start() {
        fatalError("Children should implement `start`.")
    }
}
