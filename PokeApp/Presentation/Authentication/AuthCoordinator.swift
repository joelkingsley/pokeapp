//
//  AuthCoordinator.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 21/09/21.
//

import UIKit
import Combine
import Swinject

protocol AuthCoordinatorDelegate: AnyObject {
    func authenticationComplete()
}

class AuthCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    
    weak var parentCoordinator: AuthCoordinatorDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    let window: UIWindow
    
    var navigationController: UINavigationController?
    
    let container: Container
    
    // MARK: - Lifecycle
    
    init(window: UIWindow, container: Container, navigationController :UINavigationController?) {
        self.window = window
        self.navigationController = navigationController
        self.container = container
        super.init()
    }
    
    override func start() {
        showLoginController()
    }
    
    // MARK: - Helpers
    
    func showLoginController() {
        let viewController = LoginController(loginUseCase: container.resolve(LoginUseCase.self)!)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showRegistrationController() {
        let viewController = RegistrationController(registrationUseCase: container.resolve(RegistrationUseCase.self)!)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - LoginControllerDelegate

extension AuthCoordinator: LoginControllerDelegate {
    func wantsToSignUp() {
        self.showRegistrationController()
    }
    
    func loginComplete(user: User) {
        print("DEBUG: Start tabs coordinator")
        AppContext.instance.state = .loggedIn(user)
        
        parentCoordinator?.authenticationComplete()
        isCompleted?()
    }
}

// MARK: - RegistrationControllerDelegate

extension AuthCoordinator: RegistrationControllerDelegate {
    func wantsToLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    func signUpComplete(user: User) {
        print("DEBUG: Start tabs coordinator")
        AppContext.instance.state = .loggedIn(user)
        
        parentCoordinator?.authenticationComplete()
        isCompleted?()
    }
}
