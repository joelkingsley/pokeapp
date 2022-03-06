//
//  TeamsController.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 09/09/21.
//

import UIKit
import Combine
import FloatingPanel

protocol TeamsControllerDelegate: AnyObject {
    func logoutPressed()
}

class TeamsController: UIViewController {
    // MARK: - Properties
    
    private var cancellable: AnyCancellable?
    
    var user: User?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TeamListCell.self, forCellWithReuseIdentifier: TeamListCell.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var newTeamButton: CustomTextButton = {
        let button = CustomTextButton()
        button.setLinkStyleAttributedTitle(text: "New Team")
        button.setTitleColor(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(handleNewTeamButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var displayNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont(name: "Futura Medium", size: 25.0)
        return label
    }()
    
    private lazy var xpLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont(name: "Futura Medium", size: 16.0)
        return label
    }()
    
    private lazy var floatingPanelController: FloatingPanelController = {
        let fpc = FloatingPanelController()
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.isRemovalInteractionEnabled = true
        fpc.delegate = self
        fpc.layout = FormFloatingPanelLayout()
        return fpc
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTeams), for: .valueChanged)
        return refreshControl
    }()
    
    private var allTeams = [FirestoreTeam]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var filteredTeams = [FirestoreTeam]()
    
    weak var delegate: TeamsControllerDelegate?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUserProfileSection()
        configureUI()
        configureSearchController()
        fetchTeams()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG: viewWillAppear TeamsController")
        setUserProfileSection()
    }
    
    // MARK: - Actions
    
    @objc func handleLogout() {
        print("DEBUG: Logout user here")
        delegate?.logoutPressed()
    }
    
    @objc func handleNewTeamButtonClicked() {
        print("DEBUG: Open New Team creation panel here")
        showAddPokemonsFloatingPanel()
    }
    
    @objc func refreshTeams() {
        fetchTeams()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(displayNameLabel)
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        displayNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        displayNameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        view.addSubview(xpLabel)
        xpLabel.translatesAutoresizingMaskIntoConstraints = false
        xpLabel.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor).isActive = true
        xpLabel.leftAnchor.constraint(equalTo: displayNameLabel.rightAnchor, constant: 20).isActive = true
        
        view.addSubview(newTeamButton)
        newTeamButton.translatesAutoresizingMaskIntoConstraints = false
        newTeamButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        newTeamButton.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor).isActive = true
        newTeamButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: xpLabel.bottomAnchor, constant: 10).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let title = UILabel()
        title.text = "My Teams"
        title.font = UIFont(name: "Futura Medium", size: 18.0)
        navigationItem.titleView = title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(handleLogout))
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Teams"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setUserProfileSection() {
        let state = AppContext.instance.state
        if case let AppContext.State.loggedIn(user) = state {
            self.user = user
        }
        
        guard let user = self.user else { return }
        displayNameLabel.text = user.displayName
        xpLabel.text = "\(user.xp) XP"
    }
    
    func showAddPokemonsFloatingPanel() {
        let addPokemonsController = AddPokemonsController()
        addPokemonsController.delegate = self
        floatingPanelController.set(contentViewController: addPokemonsController)
        floatingPanelController.addPanel(toParent: self)
        floatingPanelController.move(to: .full, animated: true)
    }
    
    func showEnterTeamDetailsFloatingPanel(selectedPokemons: [FirestorePokemon]) {
        let enterTeamDetailsController = EnterTeamDetailsController(selectedPokemons: selectedPokemons)
        enterTeamDetailsController.delegate = self
        floatingPanelController.set(contentViewController: enterTeamDetailsController)
        floatingPanelController.addPanel(toParent: self)
        floatingPanelController.move(to: .full, animated: true)
    }
    
    // MARK: - API
    
    func fetchTeams() {
        showLoader(true)
        guard let user = self.user else { return }
        FirestoreDatabaseProvider.getAllTeams(of: user) { result in
            switch result {
            case .success(let documentList):
                self.allTeams = documentList.list
                self.showLoader(false)
                self.refreshControl.endRefreshing()
            case .failure(let error):
                print("DEBUG: Error while fetching all teams - \(error)")
                self.allTeams.removeAll()
                self.showLoader(false)
                self.refreshControl.endRefreshing()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TeamsController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredTeams.count
        }
        return allTeams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamListCell.reuseIdentifier, for: indexPath) as! TeamListCell
        
        let team: FirestoreTeam
        if isFiltering {
            team = filteredTeams[indexPath.row]
        } else {
            team = allTeams[indexPath.row]
        }
        
        cell.viewModel = TeamListItemViewModel(team: team, isDisabled: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let team: FirestoreTeam
        if isFiltering {
            team = filteredTeams[indexPath.row]
        } else {
            team = allTeams[indexPath.row]
        }
        print("DEBUG: Team '\(team.name)' selected")
        let controller = TeamDetailController(team: team)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TeamsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = CGFloat(100)
        return CGSize(width: width, height: height)
    }
}

// MARK: - UISearchResultsUpdating

extension TeamsController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredTeams = allTeams.filter({ team in
            team.name.lowercased().contains(searchText)
        })
        
        collectionView.reloadData()
    }
}

// MARK: - FloatingPanelControllerDelegate

extension TeamsController: FloatingPanelControllerDelegate {
}

// MARK: - AddPokemonsControllerDelegate

extension TeamsController: AddPokemonsControllerDelegate {
    func wantsToCreateTeam(with pokemons: [FirestorePokemon]) {
        print("DEBUG: Pokemons selected: \(pokemons)")
        if floatingPanelController.isBeingPresented {
            floatingPanelController.removePanelFromParent(animated: true) {
                self.showEnterTeamDetailsFloatingPanel(selectedPokemons: pokemons)
            }
        } else {
            showEnterTeamDetailsFloatingPanel(selectedPokemons: pokemons)
        }
    }
}

// MARK: - EnterTeamDetailsControllerDelegate

extension TeamsController: EnterTeamDetailsControllerDelegate {
    func wantsToCreateTeam(_ team: FirestoreTeam, with pokemons: [FirestorePokemon]) {
        if var user = self.user {
            user.xp = user.xp - team.totalXp + (team.numberOfPokemonsWithGigaPower * 20)
            
            var updatedTeam = team
            updatedTeam.totalXp  = team.totalXp + (team.numberOfPokemonsWithGigaPower * 20)
            
            floatingPanelController.removePanelFromParent(animated: true)
            self.cancellable = FirestoreDatabaseProvider.createTeam(updatedTeam, for: user.uid, with: pokemons).zip(FirestoreDatabaseProvider.updateUserData(user: user))
                .sink(receiveCompletion: { completed in
                    if case .failure(let error) = completed {
                        print("DEBUG: Error while creating team and updating user - \(error.localizedDescription)")
                    }
                    print("DEBUG: Successfully completed creating team and updating user")
                }, receiveValue: { (commitResponse, updatedUser) in
                    print("DEBUG: updatedUser: \(updatedUser)")
                    let user = User(firestoreUser: updatedUser)
                    AppContext.instance.state = .loggedIn(user)
                    
                    self.fetchTeams()
                    self.setUserProfileSection()
                })

        }
    }
}
