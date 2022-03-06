//
//  AddCurrentPokemonToTeamsController.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 18/09/21.
//

import UIKit
import Combine

class AddCurrentPokemonToTeamsController: UIViewController {
    // MARK: - Properties
    
    var cancellables = Set<AnyCancellable>()
    
    private var user: User?
    
    private let addToTeamsLabel: UILabel = {
        let label = UILabel()
        label.text = "Add To Teams"
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 20)
        return label
    }()
    
    private lazy var cancelButton: CustomTextButton = {
        let button = CustomTextButton()
        button.setLinkStyleAttributedTitle(text: "Cancel")
        button.setTitleColor(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(handleCancelButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(TeamSelectCell.self, forCellWithReuseIdentifier: TeamSelectCell.reuseIdentifier)
        return collectionView
    }()
    
    let pokemon: FirestorePokemon
    
    var allTeams = [FirestoreTeam]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var addedTeams = [FirestoreTeam]()
    
    var teamsThatAlreadyHaveThisPokemon = [String]()
    
    var isAddingToTeamsAllowed = true
    
    // MARK: - Lifecycle
    
    init(pokemon: FirestorePokemon) {
        self.pokemon = pokemon
        
        let state = AppContext.instance.state
        if case let AppContext.State.loggedIn(user) = state {
            self.user = user
            self.isAddingToTeamsAllowed = user.xp >= pokemon.xp
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchAllTeams()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("DEBUG: viewWillAppear")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout();
    }
    
    // MARK: - Actions
    
    @objc func handleCancelButtonClicked() {
        print("DEBUG: Cancel button clicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(addToTeamsLabel)
        addToTeamsLabel.translatesAutoresizingMaskIntoConstraints = false
        addToTeamsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        addToTeamsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addToTeamsLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: addToTeamsLabel.bottomAnchor, constant: 20).isActive = true
    }
    
    func updateForm() {
        if let user = self.user {
            isAddingToTeamsAllowed = user.xp >= pokemon.xp
        } else {
            print("DEBUG: User not initialized")
        }
    }
    
    // MARK: - API
    
    func fetchAllTeams() {
        guard let user = user else { return }
        showLoader(true)
        
        FirestoreDatabaseProvider.getAllTeams(of: user) { result in
            switch result {
            case .success(let documentList):
                FirestoreDatabaseProvider.getTeamsThatHaveThisPokemon(self.pokemon)
                    .sink { completed in
                        if case .failure(let error) = completed {
                            print("DEBUG: Got error: \(error.localizedDescription)")
                            self.allTeams = documentList.list
                            self.teamsThatAlreadyHaveThisPokemon = []
                            self.showLoader(false)
                        }
                    } receiveValue: { teamsThatAlreadyHaveThisPokemon in
                        self.teamsThatAlreadyHaveThisPokemon = teamsThatAlreadyHaveThisPokemon
                        self.allTeams = documentList.list
                        self.showLoader(false)
                    }.store(in: &self.cancellables)
            case .failure(let error):
                print("DEBUG: Error occurred while fetching teams from firestore - \(error)")
                self.allTeams = []
                self.teamsThatAlreadyHaveThisPokemon = []
                self.showLoader(false)
            }
        }
    }
    
}
// MARK: - UICollectionViewDataSource

extension AddCurrentPokemonToTeamsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTeams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamSelectCell.reuseIdentifier, for: indexPath) as! TeamSelectCell
        cell.delegate = self
        if let teamId = self.allTeams[indexPath.row].teamId {
            if teamsThatAlreadyHaveThisPokemon.contains(teamId) {
                cell.viewModel = TeamListItemViewModel(team: self.allTeams[indexPath.row], isDisabled: true)
                cell.viewModel?.hasSelectedPokemon = true
            } else {
                cell.viewModel = TeamListItemViewModel(team: self.allTeams[indexPath.row], isDisabled: !isAddingToTeamsAllowed)
                cell.viewModel?.hasSelectedPokemon = false
            }
        } else {
            cell.viewModel = TeamListItemViewModel(team: self.allTeams[indexPath.row], isDisabled: !isAddingToTeamsAllowed)
        }
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AddCurrentPokemonToTeamsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = CGFloat(50)
        return CGSize(width: width, height: height)
    }
}

// MARK: - TeamSelectCellDelegate

extension AddCurrentPokemonToTeamsController: TeamSelectCellDelegate {
    func cell(_ cell: TeamSelectCell, wantsToAddPokemonToTeam team: FirestoreTeam) {
        if var user = self.user {
            user.xp = user.xp - pokemon.xp
            
            var updatedTeam = team
            updatedTeam.totalXp  = team.totalXp + pokemon.xp + (pokemon.hasGigaPower ? 20 : 0)
            
            FirestoreDatabaseProvider.addPokemonsToTeam(pokemons: [pokemon], team: updatedTeam, of: user)
                .zip(FirestoreDatabaseProvider.updateUserData(user: user), FirestoreDatabaseProvider.updateTeamDetails(team: team, user: FirestoreUser(user: user)))
                .sink { completed in
                    if case .failure(let error) = completed {
                        print("DEBUG: Error occurred while adding pokemon \(self.pokemon.number) - \(error.localizedDescription)")
                    }
                } receiveValue: { (commitResponse, updatedUser, updatedTeam) in
                    print("Added pokemon \(self.pokemon.number) to team \(team.name)")
                    let user = User(firestoreUser: updatedUser)
                    AppContext.instance.state = .loggedIn(user)
                }
                .store(in: &cancellables)
            
            fetchAllTeams()
            
            updateForm()
        }
    }
}
