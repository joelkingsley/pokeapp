//
//  PokemonDetailController.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 09/09/21.
//

import UIKit
import Combine

class PokemonDetailController: UIViewController {
    // MARK: - Views
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let scrollViewContainer: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .center
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardView: UIView = {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        
        card.layer.cornerRadius = 10
        card.layer.masksToBounds = true
        card.layer.borderColor = UIColor.gray.cgColor
        card.layer.borderWidth = 0.5

        card.layer.contentsScale = UIScreen.main.scale
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 0)
        card.layer.shadowRadius = 5.0
        card.layer.shadowOpacity = 0.5
        card.layer.masksToBounds = false
        card.clipsToBounds = false

        card.isHidden = true
        return card
    }()
    
    private let cardFillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 330).isActive = true
        view.heightAnchor.constraint(equalToConstant: 520).isActive = true
        view.isHidden = true
        return view
    }()
    
    private let imageBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 310).isActive = true
        view.heightAnchor.constraint(equalToConstant: 270).isActive = true
        
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 0.5

        view.layer.contentsScale = UIScreen.main.scale
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 5.0
        view.layer.shadowOpacity = 0.5
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        view.isHidden = true
        return view
    }()
    
    private lazy var detailsView: UIView = {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: 310).isActive = true
        view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        view.isHidden = true
        return view
    }()
    
    // MARK: - Properties
    
    var cancellables = Set<AnyCancellable>()
    
    private lazy var spriteImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()
    
    private lazy var nationalNumberLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Futura Medium", size: 24)
        label.textColor = .black
        label.isHidden = true
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 22)
        label.isHidden = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 18)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var xpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura Medium", size: 14)
        label.textColor = .black
        label.isHidden = true
        return label
    }()
    
    private lazy var speciesLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    private lazy var weightLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    private lazy var generationLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    private let pokemonNumber: String
    
    var viewModel: PokemonDetailViewModel? {
        didSet {
            setColors()
            configure()
        }
    }
    
    // MARK: - Lifecycle
    
    init(pokemonNumber: String) {
        self.pokemonNumber = pokemonNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchPokemonDetail(for: self.pokemonNumber)
    }
    
    // MARK: - Actions
    
    // MARK: - Helpers
    
    func configureUI() {
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContainer)
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        scrollViewContainer.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        scrollViewContainer.widthAnchor.constraint(equalToConstant: 350).isActive = true
        
        scrollViewContainer.addArrangedSubview(cardView)
        cardView.centerXAnchor.constraint(equalTo: scrollViewContainer.centerXAnchor).isActive = true
        cardView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
        cardView.widthAnchor.constraint(equalToConstant: 350).isActive = true
        cardView.heightAnchor.constraint(equalToConstant: 550).isActive = true
        
        cardView.addSubview(cardFillView)
        cardFillView.translatesAutoresizingMaskIntoConstraints = false
        cardFillView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        cardFillView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor).isActive = true
        
        cardFillView.addSubview(nationalNumberLabel)
        nationalNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        nationalNumberLabel.leftAnchor.constraint(equalTo: cardFillView.leftAnchor, constant: 10).isActive = true
        nationalNumberLabel.topAnchor.constraint(equalTo: cardFillView.topAnchor, constant: 10).isActive = true

        cardFillView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: nationalNumberLabel.rightAnchor, constant: 10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: cardFillView.topAnchor, constant: 10).isActive = true
        
        cardFillView.addSubview(imageBackground)
        imageBackground.translatesAutoresizingMaskIntoConstraints = false
        imageBackground.topAnchor.constraint(equalTo: nationalNumberLabel.bottomAnchor, constant: 10).isActive = true
        imageBackground.centerXAnchor.constraint(equalTo: cardFillView.centerXAnchor).isActive = true
        
        imageBackground.addSubview(spriteImageView)
        spriteImageView.translatesAutoresizingMaskIntoConstraints = false
        spriteImageView.topAnchor.constraint(equalTo: imageBackground.topAnchor, constant: 15).isActive = true
        spriteImageView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        spriteImageView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        spriteImageView.centerXAnchor.constraint(equalTo: imageBackground.centerXAnchor).isActive = true
        
        cardFillView.addSubview(xpLabel)
        xpLabel.translatesAutoresizingMaskIntoConstraints = false
        xpLabel.topAnchor.constraint(equalTo: cardFillView.topAnchor, constant: 10).isActive = true
        xpLabel.rightAnchor.constraint(equalTo: cardFillView.rightAnchor, constant: -10).isActive = true
        
        cardFillView.addSubview(detailsView)
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        detailsView.topAnchor.constraint(equalTo: imageBackground.bottomAnchor, constant: 10).isActive = true
        detailsView.centerXAnchor.constraint(equalTo: cardFillView.centerXAnchor).isActive = true

        detailsView.addSubview(speciesLabel)
        speciesLabel.translatesAutoresizingMaskIntoConstraints = false
        speciesLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 10).isActive = true
        speciesLabel.leftAnchor.constraint(equalTo: detailsView.leftAnchor, constant: 10).isActive = true
        
        detailsView.addSubview(weightLabel)
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        weightLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 10).isActive = true
        weightLabel.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor).isActive = true
        
        detailsView.addSubview(generationLabel)
        generationLabel.translatesAutoresizingMaskIntoConstraints = false
        generationLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 10).isActive = true
        generationLabel.rightAnchor.constraint(equalTo: detailsView.rightAnchor, constant: -10).isActive = true
        
        detailsView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: -10).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: detailsView.leftAnchor, constant: 5).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: detailsView.rightAnchor, constant: -5).isActive = true
    }
    
    func configure() {
        guard let viewModel = self.viewModel else { return }
        spriteImageView.sd_setImage(with: viewModel.spriteImageUrl) { image, error, type, url in
            self.nameLabel.text = viewModel.pokemonName
            self.nationalNumberLabel.text = viewModel.nationalNumber
            self.nameLabel.text = viewModel.pokemonName
            self.descriptionLabel.text = viewModel.description
            self.weightLabel.attributedText = viewModel.weight
            self.speciesLabel.attributedText = viewModel.speciesName
            self.generationLabel.attributedText = viewModel.generation
            self.xpLabel.attributedText = viewModel.xp
            
            self.unHideAllViews()
        }
    }
    
    func unHideAllViews() {
        cardView.isHidden = false
        cardFillView.isHidden = false
        imageBackground.isHidden = false
        detailsView.isHidden = false
        spriteImageView.isHidden = false
        nationalNumberLabel.isHidden = false
        nameLabel.isHidden = false
        descriptionLabel.isHidden = false
        speciesLabel.isHidden = false
        weightLabel.isHidden = false
        generationLabel.isHidden = false
        xpLabel.isHidden = false
    }
    
    func setColors() {
        guard let viewModel = viewModel else { return }
        
        let backgroundColor = UIColor(hex: viewModel.pokemon.spriteBackgroundColor)
        self.cardView.backgroundColor = .systemYellow
        self.cardFillView.backgroundColor = backgroundColor
        
        if backgroundColor.isDark {
            self.nationalNumberLabel.textColor = .white
            self.nameLabel.textColor = .white
            self.speciesLabel.textColor = .white
            self.xpLabel.textColor = .white
            self.weightLabel.textColor = .white
            self.generationLabel.textColor = .white
        } else {
            self.nationalNumberLabel.textColor = .black
            self.nameLabel.textColor = .black
            self.speciesLabel.textColor = .black
            self.xpLabel.textColor = .black
            self.weightLabel.textColor = .black
            self.generationLabel.textColor = .black
        }
        
        self.imageBackground.setGradientBackground(colorTop: UIColor(hex: viewModel.pokemon.spritePrimaryColor), colorBottom: UIColor(hex: viewModel.pokemon.spriteSecondaryColor))
        self.detailsView.setGradientBackground(colorTop: backgroundColor, colorBottom: .white)
    }
    
    // MARK: - API
    
    func fetchPokemonDetail(for pokemonNumber: String) {
        showLoader(true)
        PokedexAPIProvider.fetchPokemon(number: pokemonNumber)
            .zip(FirestoreDatabaseProvider.getPokemon(number: pokemonNumber))
            .sink(receiveCompletion: { completed in
                if case .failure(let error) = completed {
                    print("DEBUG: Got error: \(error.localizedDescription)")
                }
            }, receiveValue: { pokedexPokemon, firestorePokemon in
                var pokemon = pokedexPokemon
                pokemon.setOptionalPropertiesFromFirestore(with: firestorePokemon)
                self.viewModel = PokemonDetailViewModel(pokemon: pokemon)
                self.showLoader(false)
            }).store(in: &cancellables)
    }
}
