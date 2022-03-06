//
//  NewTeamCell.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 07/09/21.
//

import UIKit
import SDWebImage

protocol NewTeamCellDelegate: AnyObject {
    func cell(_ cell: NewTeamCell, wantsToToggleAddToTeam pokemon: FirestorePokemon)
}

class NewTeamCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "NewTeamCell"
    
    // MARK: - Properties
    
    var viewModel: PokemonListItemViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: NewTeamCellDelegate?
    
    private lazy var spriteImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true

        return iv
    }()
    
    private lazy var nationalNumberLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Futura Medium", size: 22.0)
        label.textColor = .gray
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 20.0)
        return label
    }()
    
    private lazy var xpLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 12.0)
        return label
    }()
    
    private lazy var checkbox: CustomCheckbox = {
        let checkbox = CustomCheckbox(type: .system)
        return checkbox
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(checkbox)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.heightAnchor.constraint(equalToConstant: 20).isActive = true
        checkbox.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        checkbox.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        addSubview(spriteImageView)
        spriteImageView.translatesAutoresizingMaskIntoConstraints = false
        spriteImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        spriteImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        spriteImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        spriteImageView.leftAnchor.constraint(equalTo: checkbox.leftAnchor, constant: 40).isActive = true
        
        addSubview(nationalNumberLabel)
        nationalNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        nationalNumberLabel.leftAnchor.constraint(equalTo: spriteImageView.rightAnchor, constant: 20).isActive = true
        nationalNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: nationalNumberLabel.rightAnchor, constant: 10).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        addSubview(xpLabel)
        xpLabel.translatesAutoresizingMaskIntoConstraints = false
        xpLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        xpLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCellSelected)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled else { return nil }
        guard !isHidden else { return nil }
        guard alpha >= 0.01 else { return nil }
        guard self.point(inside: point, with: event) else { return nil }
        
        return super.hitTest(point, with: event)
    }
    
    @objc func handleCellSelected() {
        if (!checkbox.shouldDisable) {
            guard let viewModel = viewModel else { return }
            delegate?.cell(self, wantsToToggleAddToTeam: viewModel.pokemon)
        }
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        spriteImageView.sd_setImage(with: viewModel.spriteImageUrl, completed: nil)
        nationalNumberLabel.text = viewModel.nationalNumber
        nameLabel.text = viewModel.pokemonName
        xpLabel.text = viewModel.xp
        checkbox.isChecked = viewModel.isAddedToTeam
        if viewModel.isDisabled {
            checkbox.shouldDisable = true
        } else {
            checkbox.shouldDisable = false
        }
    }
    
    // MARK: - API
}
