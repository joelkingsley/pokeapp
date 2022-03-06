//
//  AppCoordinator.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 21/09/21.
//

import UIKit
import Combine
import Swinject

class AppCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    
    var canellables = Set<AnyCancellable>()
    
    let window : UIWindow
    
    var navigationController: UINavigationController?
    
    let container: Container
    
    let checkIfAuthenticatedUseCase: CheckIfAuthenticatedUseCase
    
    // MARK: - Lifecycle
    
    init(window: UIWindow, container: Container) {
        self.window = window
        self.container = container
        self.checkIfAuthenticatedUseCase = container.resolve(CheckIfAuthenticatedUseCase.self)!
        super.init()
    }
    
    override func start() {
        checkIfAuthenticated()
            .sink { completed in
                if case .failure(_) = completed {
                    self.goToAuthCoordinator()
                } else {
                    self.goToTabsCoordinator()
                }
            } receiveValue: { user in
                AppContext.instance.state = .loggedIn(user)
            }
            .store(in: &canellables)
    }
    
    // MARK: - Properties
    
    func goToAuthCoordinator() {
        
        initializeWindow()
        
        let authCoordinator = AuthCoordinator(window: window, container: container, navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        
        self.store(coordinator: authCoordinator)
        authCoordinator.start()
        
        authCoordinator.isCompleted = { [weak self] in
            self?.free(coordinator: authCoordinator)
        }
    }
    
    func goToTabsCoordinator() {
        
        let tabsCoordinator = TabsCoordinator(window: window)
        tabsCoordinator.parentCoordinator = self
        
        self.store(coordinator: tabsCoordinator)
        tabsCoordinator.start()
        
        tabsCoordinator.isCompleted = { [weak self] in
            self?.free(coordinator: tabsCoordinator)
        }
    }
    
    // MARK: - Helpers
    
    func initializeWindow() {
        self.navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    // MARK: - API
    
    func checkIfAuthenticated() -> AnyPublisher<User, Error> {
        return checkIfAuthenticatedUseCase.execute()
    }
}

// MARK: - AuthCoordinatorDelegate

extension AppCoordinator: AuthCoordinatorDelegate {
    func authenticationComplete() {
        goToTabsCoordinator()
    }
}

// MARK: - TabsCoordinatorDelegate

extension AppCoordinator: TabsCoordinatorDelegate {
    func logoutUser() {
        print("DEBUG: AppCoordinator logoutUser")
        goToAuthCoordinator()
    }
}
