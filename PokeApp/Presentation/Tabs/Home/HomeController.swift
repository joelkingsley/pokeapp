//
//  HomeController.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 20/08/21.
//

import UIKit
import FloatingPanel
import CoreData
import Combine

protocol HomeControllerDelegate: AnyObject {
    func logoutPressed()
}

class HomeController: UIViewController {
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    var user: User?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomePokemonCardCell.self, forCellWithReuseIdentifier: HomePokemonCardCell.reuseIdentifier)
        return collectionView
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
        label.text = "100"
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
        refreshControl.addTarget(self, action: #selector(refreshPokemons), for: .valueChanged)
        return refreshControl
    }()
    
    private var allPokemons = [FirestorePokemon]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var filteredPokemons = [FirestorePokemon]()
    
    weak var delegate: HomeControllerDelegate?
    
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
        fetchPokemons()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG: viewWillAppear HomeController")
        setUserProfileSection()
    }
    
    // MARK: - Actions
    
    @objc func handleLogout() {
        print("DEBUG: Logout user here")
        delegate?.logoutPressed()
    }
    
    @objc func refreshPokemons() {
        fetchPokemons()
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
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 10).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let title = UILabel()
        title.text = "Home"
        title.font = UIFont(name: "Futura Medium", size: 18.0)
        navigationItem.titleView = title
        
        let quitButton = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(handleLogout))
        quitButton.tintColor = .label
        navigationItem.leftBarButtonItem = quitButton
        
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
        searchController.searchBar.placeholder = "Search Pokemons"
        searchController.searchBar.tintColor = .label
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
    
    // MARK: - API
    
    func fetchPokemons() {
        showLoader(true)
        
        FirestoreDatabaseProvider.getAllPokemons { result in
            switch result {
            case .success(let documentList):
                self.allPokemons = documentList.list
                self.showLoader(false)
                self.refreshControl.endRefreshing()
            case .failure(let error):
                print("DEBUG: Error occurred while fetching pokemon details from firestore - \(error)")
                self.allPokemons.removeAll()
                self.showLoader(false)
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func addAllPokemonsToFirestore() {
        PokedexAPIProvider.fetchPokemons(from: 1, to: 150) { pokemons in
            pokemons.forEach({ pokemon in
                var newPokemon = pokemon
                newPokemon.xp = Int.getUniqueRandomNumbers(min: 5, max: 10, count: 1).first!
                FirestoreDatabaseProvider.createNewPokemon(pokemon: newPokemon) { error in
                    if let error = error {
                        print("DEBUG: Error in pokemon \(error)")
                        return
                    }
                    print("DEBUG: Created pokemon \(pokemon.number)")
                }
            })
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HomeController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPokemons.count
        }
        return allPokemons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePokemonCardCell.reuseIdentifier, for: indexPath) as! HomePokemonCardCell
        cell.delegate = self
        
        let pokemon: FirestorePokemon
        if isFiltering {
            pokemon = filteredPokemons[indexPath.row]
        } else {
            pokemon = allPokemons[indexPath.row]
        }

        cell.viewModel = PokemonListItemViewModel(pokemon: pokemon, isDisabled: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemon: FirestorePokemon
        if isFiltering {
            pokemon = filteredPokemons[indexPath.row]
        } else {
            pokemon = allPokemons[indexPath.row]
        }
        print("DEBUG: Pokemon \(pokemon.number) selected")
        let controller = PokemonDetailController(pokemonNumber: pokemon.number)
        controller.modalPresentationStyle = .overCurrentContext
        self.navigationController?.pushViewController(controller, animated: false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    private var cellWidth: CGFloat {
        return 150.0
    }
    private var cellHeight: CGFloat {
        return 250.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let numberOfCells = floor(collectionView.frame.size.width / (cellWidth+10))
        let edgeInsets = (collectionView.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
        return UIEdgeInsets(top: 15, left: edgeInsets, bottom: 0, right: edgeInsets)
    }
    
}

// MARK: - UISearchResultsUpdating

extension HomeController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredPokemons = allPokemons.filter({ pokemon in
            pokemon.name.lowercased().contains(searchText) || pokemon.species.lowercased().contains(searchText)
        })
        
        collectionView.reloadData()
    }
}

// MARK: - HomePokemonCardCellDelegate

extension HomeController: HomePokemonCardCellDelegate {
    func wantsToAddPokemonToATeam(_ cell: HomePokemonCardCell, pokemon: FirestorePokemon) {
        print("DEBUG: Pokemon \(pokemon.number) selected")
        showAddPokemonToTeamFloatingPanel(for: pokemon)
    }
  
    func showAddPokemonToTeamFloatingPanel(for pokemon: FirestorePokemon) {
        let addCurrentPokemonToTeamsController = AddCurrentPokemonToTeamsController(pokemon: pokemon)
        floatingPanelController.set(contentViewController: addCurrentPokemonToTeamsController)
        floatingPanelController.addPanel(toParent: self)
        floatingPanelController.move(to: .full, animated: true)
    }
}

// MARK: - FloatingPanelControllerDelegate

extension HomeController: FloatingPanelControllerDelegate {
}
