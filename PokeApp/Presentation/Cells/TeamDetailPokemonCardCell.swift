//
//  TeamDetailPokemonCardCell.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 16/09/21.
//

import UIKit

class TeamDetailPokemonCardCell: UICollectionViewCell {
    public static let reuseIdentifier = "TeamDetailPokemonCardCell"
    
    // MARK: - Properties
    
    var viewModel: PokemonListItemViewModel? {
        didSet {
            setColors()
            configure()
        }
    }
    
    private lazy var spriteImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.heightAnchor.constraint(equalToConstant: 100).isActive = true
        iv.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return iv
    }()
    
    private lazy var nationalNumberLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Futura Medium", size: 17.0)
        label.textColor = .black
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 15.0)
        return label
    }()
    
    private lazy var speciesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var xpLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 12.0)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemYellow
        
        addSubview(nationalNumberLabel)
        nationalNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        nationalNumberLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        nationalNumberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        nationalNumberLabel.isHidden = true

        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: nationalNumberLabel.rightAnchor, constant: 8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        nameLabel.isHidden = true
        
        addSubview(spriteImageView)
        spriteImageView.translatesAutoresizingMaskIntoConstraints = false
        spriteImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        spriteImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        spriteImageView.isHidden = true

        addSubview(speciesLabel)
        speciesLabel.translatesAutoresizingMaskIntoConstraints = false
        speciesLabel.topAnchor.constraint(equalTo: spriteImageView.bottomAnchor, constant: 10).isActive = true
        speciesLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        speciesLabel.isHidden = true

        addSubview(xpLabel)
        xpLabel.translatesAutoresizingMaskIntoConstraints = false
        xpLabel.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        xpLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        xpLabel.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        spriteImageView.sd_setImage(with: viewModel.spriteImageUrl) { image, error, type, url in
            self.nationalNumberLabel.text = viewModel.nationalNumber
            self.nameLabel.text = viewModel.pokemonName
            self.speciesLabel.attributedText = viewModel.speciesName
            self.xpLabel.text = viewModel.xp
            
            self.nationalNumberLabel.isHidden = false
            self.nameLabel.isHidden = false
            self.speciesLabel.isHidden = false
            self.xpLabel.isHidden = false
            self.spriteImageView.isHidden = false
        }
        
    }
    
    func setColors() {
        guard let viewModel = viewModel else { return }
        let backgroundColor = UIColor(hex: viewModel.pokemon.spriteBackgroundColor)
        self.contentView.backgroundColor = backgroundColor

        if backgroundColor.isDark {
            self.nationalNumberLabel.textColor = .white
            self.nameLabel.textColor = .white
            self.speciesLabel.textColor = .white
            self.xpLabel.textColor = .white
        } else {
            self.nationalNumberLabel.textColor = .black
            self.nameLabel.textColor = .black
            self.speciesLabel.textColor = .black
            self.xpLabel.textColor = .black
        }
    }

}

