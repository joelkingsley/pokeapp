//
//  TeamDetailController.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 14/09/21.
//

import UIKit
import Combine
import FloatingPanel

class TeamDetailController: UIViewController {
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    var user: User?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(TeamDetailPokemonCardCell.self, forCellWithReuseIdentifier: TeamDetailPokemonCardCell.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var addPokemonButton: CustomTextButton = {
        let button = CustomTextButton()
        button.setLinkStyleAttributedTitle(text: "Add Pokemons")
        button.setTitleColor(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(handleAddPokemonsButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var teamNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Futura Medium", size: 15.0)
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.textAlignment = .center
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
    
    private var team: FirestoreTeam
    
    private var allPokemons = [FirestorePokemon]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var filteredPokemons = [FirestorePokemon]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: - Lifecycle
    
    init(team: FirestoreTeam) {
        self.team = team
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let state = AppContext.instance.state
        if case let AppContext.State.loggedIn(user) = state {
            self.user = user
        }
        
        configureUI()
        fetchPokemonsInTeam()
    }
    
    // MARK: - Actions
    
    @objc func handleAddPokemonsButtonClicked() {
        print("DEBUG: Display add pokemons to existing team floating panel here")
        showAddPokemonsFloatingPanel()
    }
    
    @objc func refreshPokemons() {
        fetchPokemonsInTeam()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.addSubview(addPokemonButton)
        addPokemonButton.translatesAutoresizingMaskIntoConstraints = false
        addPokemonButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addPokemonButton.widthAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width).isActive = true
        addPokemonButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        addPokemonButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: addPokemonButton.bottomAnchor, constant: 10).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        navigationItem.titleView = teamNameLabel
        
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
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func showAddPokemonsFloatingPanel() {
        showLoader(true)
        FirestoreDatabaseProvider.getAllPokemons { result in
            switch result {
            case .success(let documentList):
                let addPokemonsController = AddPokemonsToExistingTeamController(allPokemons: documentList.list, existingPokemons: self.allPokemons)
                addPokemonsController.delegate = self
                self.floatingPanelController.set(contentViewController: addPokemonsController)
                self.floatingPanelController.addPanel(toParent: self)
                self.floatingPanelController.move(to: .full, animated: true)
                self.showLoader(false)
            case .failure(let error):
                print("DEBUG: Error while fetching all pokemons from Firestore - \(error)")
                self.showLoader(false)
            }
        }
    }
    
    // MARK: - API
    
    func fetchPokemonsInTeam() {
        guard let user = self.user else { return }
        FirestoreDatabaseProvider.getPokemonsinTeam(self.team, of: user)
            .sink { completed in
                if case .failure(let error) = completed {
                    print("DEBUG: Error occurred while getting pokemons in team - \(error.localizedDescription)")
                    self.allPokemons.removeAll()
                    self.refreshControl.endRefreshing()
                }
                print("DEBUG: Completed fetching pokemons in team '\(self.team.name)'")
            } receiveValue: { documentList in
                self.allPokemons = documentList.list
                self.teamNameLabel.text = "\(self.team.name) (\(self.allPokemons.count)/12)"
                self.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
    }
    
    func addPokemonsToTeam(pokemons: [FirestorePokemon]) {
        guard let user = user else { return }
        FirestoreDatabaseProvider.addPokemonsToTeam(pokemons: pokemons, team: team, of: user)
            .sink { completed in
                if case .failure(let error) = completed {
                    print("DEBUG: Error occurred while adding pokemons to team - \(error.localizedDescription)")
                }
            } receiveValue: { commitResponse in
                print("DEBUG: Added pokemons to team")
                self.fetchPokemonsInTeam()
            }
            .store(in: &cancellables)

    }
}

// MARK: - UICollectionViewDataSource

extension TeamDetailController: UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamDetailPokemonCardCell.reuseIdentifier, for: indexPath) as! TeamDetailPokemonCardCell
        
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
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TeamDetailController: UICollectionViewDelegateFlowLayout {
    
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

// MARK: - FloatingPanelControllerDelegate

extension TeamDetailController: FloatingPanelControllerDelegate {
}

// MARK: - AddPokemonsControllerDelegate

extension TeamDetailController: AddPokemonsToExistingTeamControllerDelegate {
    func wantsToAddPokemons(_ pokemons: [FirestorePokemon]) {
        print("DEBUG: Pokemons to add: \(pokemons)")
        floatingPanelController.removePanelFromParent(animated: true)
        addPokemonsToTeam(pokemons: pokemons)
    }
}

// MARK: - UISearchResultsUpdating

extension TeamDetailController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredPokemons = allPokemons.filter({ pokemon in
            pokemon.name.lowercased().contains(searchText) || pokemon.species.lowercased().contains(searchText)
        })
        
        collectionView.reloadData()
    }
}

