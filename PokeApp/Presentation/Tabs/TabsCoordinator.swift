//
//  TabsCoordinator.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 21/09/21.
//

import UIKit

protocol TabsCoordinatorDelegate: AnyObject {
    func logoutUser()
}

class TabsCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    
    weak var parentCoordinator: TabsCoordinatorDelegate?
    
    let window: UIWindow
    
    var navigationController: UINavigationController?
    
    // MARK: - Lifecycle
    
    init(window: UIWindow) {
        self.window = window
        super.init()
    }
    
    override func start() {
        let mainTabController = MainTabController()
        mainTabController.coordinator = self
        navigationController = UINavigationController(rootViewController: mainTabController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
}

extension TabsCoordinator: MainTabControllerDelegate {
    func logoutPressed() {
        print("DEBUG: logoutPressed")
        KeychainProvider.removeIdToken()
        KeychainProvider.removeRefreshToken()
        AppContext.instance.state = .unregistered
        
        parentCoordinator?.logoutUser()
        isCompleted?()
    }
}
