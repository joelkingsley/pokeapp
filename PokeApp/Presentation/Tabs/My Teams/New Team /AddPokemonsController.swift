//
//  AddPokemonsController.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 08/09/21.
//

import UIKit

protocol AddPokemonsControllerDelegate: AnyObject {
    func wantsToCreateTeam(with pokemons: [FirestorePokemon])
}

class AddPokemonsController: UIViewController {
    // MARK: - Properties
    
    private var user: User?
    
    private let addPokemonsLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Pokemons"
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
    
    private lazy var nextButton: CustomTextButton = {
        let button = CustomTextButton()
        button.setLinkStyleAttributedTitle(text: "Next")
        button.isEnabled = false
        button.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .disabled)
        button.addTarget(self, action: #selector(handleNextButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(NewTeamCell.self, forCellWithReuseIdentifier: NewTeamCell.reuseIdentifier)
        return collectionView
    }()
    
    weak var delegate: AddPokemonsControllerDelegate?
    
    var allPokemons = [FirestorePokemon]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var addedPokemons = [FirestorePokemon]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let state = AppContext.instance.state
        if case let AppContext.State.loggedIn(user) = state {
            self.user = user
        }
        
        configureUI()
        fetchAllPokemons()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout();
    }
    
    // MARK: - Actions
    
    @objc func handleCancelButtonClicked() {
        print("DEBUG: Cancel button clicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNextButtonClicked() {
        print("DEBUG: Next button clicked")
        delegate?.wantsToCreateTeam(with: addedPokemons)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(addPokemonsLabel)
        addPokemonsLabel.translatesAutoresizingMaskIntoConstraints = false
        addPokemonsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        addPokemonsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addPokemonsLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: addPokemonsLabel.bottomAnchor, constant: 20).isActive = true
    }
    
    func updateForm() {
        if let user = self.user {
            let totalCostToAddPokemons = addedPokemons.map({ $0.xp }).reduce(0, +)
            let isAddingPokemonsAllowed = (addedPokemons.count > 0) && (totalCostToAddPokemons <= user.xp)
            
            if isAddingPokemonsAllowed {
                nextButton.isEnabled = true
                nextButton.setTitleColor(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), for: .normal)
            } else {
                nextButton.isEnabled = false
                nextButton.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .disabled)
            }
        } else {
            print("DEBUG: User not initialized")
        }
    }
    
    // MARK: - API
    
    func fetchAllPokemons() {
        showLoader(true)
        
        FirestoreDatabaseProvider.getAllPokemons { result in
            switch result {
            case .success(let documentList):
                self.allPokemons = documentList.list
                self.showLoader(false)
            case .failure(let error):
                print("DEBUG: Error occurred while fetching pokemon details from firestore - \(error)")
                self.showLoader(false)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension AddPokemonsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPokemons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewTeamCell.reuseIdentifier, for: indexPath) as! NewTeamCell
        cell.delegate = self
        cell.viewModel = PokemonListItemViewModel(pokemon: self.allPokemons[indexPath.row], isDisabled: false)
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AddPokemonsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = CGFloat(50)
        return CGSize(width: width, height: height)
    }
}

// MARK: - NewTeamCellDelegate

extension AddPokemonsController: NewTeamCellDelegate {
    func cell(_ cell: NewTeamCell, wantsToToggleAddToTeam pokemon: FirestorePokemon) {
        
        if let isAddedToTeam = cell.viewModel?.isAddedToTeam {
            if isAddedToTeam {
                print("DEBUG: Remove pokemon \(pokemon.number) from team")
                addedPokemons.removeAll(where: { $0.number == pokemon.number })
            } else {
                addedPokemons.append(pokemon)
                print("DEBUG: Added pokemon \(pokemon.number) to team")
            }
        }
        
        cell.viewModel?.isAddedToTeam.toggle()
        
        updateForm()
    }
}
