//
//  MainTabController.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 12/08/21.
//

import UIKit
import KeychainAccess
import JGProgressHUD

protocol MainTabControllerDelegate: AnyObject {
    func logoutPressed()
}

class MainTabController: UITabBarController {
    // MARK: - Properties
    
    var user: User?
    
    weak var coordinator: MainTabControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Actions
    
    // MARK: - Helpers
    
    func configureViewControllers() {
        
        view.backgroundColor = .systemBackground
        
        let homeController = HomeController()
        homeController.delegate = self
        let home = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: homeController)
        
        let teamsController = TeamsController()
        teamsController.delegate = self
        let myTeams = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "pokemon-outline"), selectedImage: #imageLiteral(resourceName: "pokemon-filled"), rootViewController: teamsController)
        viewControllers = [home, myTeams]
        
        tabBar.tintColor = .label
    }
    
    func templateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
    
    // MARK: - API
    
}

// MARK: - HomeControllerDelegate, TeamsControllerDelegate

extension MainTabController: HomeControllerDelegate, TeamsControllerDelegate {
    func logoutPressed() {
        coordinator?.logoutPressed()
    }
}
