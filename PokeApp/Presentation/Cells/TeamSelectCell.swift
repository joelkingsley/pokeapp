//
//  TeamSelectCell.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 18/09/21.
//

import UIKit
import SDWebImage

protocol TeamSelectCellDelegate: AnyObject {
    func cell(_ cell: TeamSelectCell, wantsToAddPokemonToTeam team: FirestoreTeam)
}

class TeamSelectCell: UICollectionViewCell {
    public static let reuseIdentifier = "TeamSelectCell"
    
    // MARK: - Properties
    
    var viewModel: TeamListItemViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: TeamSelectCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true

        return iv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 20.0)
        return label
    }()
    
    private lazy var totalXpLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Futura Medium", size: 12.0)
        return label
    }()
    
    private lazy var numberOfGigaPowerPokemonsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Avenir", size: 15.0)
        label.text = "Giga Impacts: "
        return label
    }()
    
    private lazy var gigaPowerCounter: GigaPowerCounter = {
        let gpc = GigaPowerCounter(count: 0)
        return gpc
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
        
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: checkbox.rightAnchor, constant: 20).isActive = true
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 20).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        addSubview(numberOfGigaPowerPokemonsLabel)
        numberOfGigaPowerPokemonsLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfGigaPowerPokemonsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        numberOfGigaPowerPokemonsLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 20).isActive = true
        
        addSubview(gigaPowerCounter)
        gigaPowerCounter.translatesAutoresizingMaskIntoConstraints = false
        gigaPowerCounter.centerYAnchor.constraint(equalTo: numberOfGigaPowerPokemonsLabel.centerYAnchor, constant: 3).isActive = true
        gigaPowerCounter.leftAnchor.constraint(equalTo: numberOfGigaPowerPokemonsLabel.rightAnchor).isActive = true
        
        addSubview(totalXpLabel)
        totalXpLabel.translatesAutoresizingMaskIntoConstraints = false
        totalXpLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        totalXpLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
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
        print("DEBUG: handleCellSelected disabled=\(checkbox.shouldDisable)")
        if !checkbox.shouldDisable {
            guard let viewModel = viewModel else { return }
            delegate?.cell(self, wantsToAddPokemonToTeam: viewModel.team)
        }
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, placeholderImage: #imageLiteral(resourceName: "icons8-cat-profile-100"), options: SDWebImageOptions(), completed: nil)
        nameLabel.text = viewModel.teamName
        totalXpLabel.text = viewModel.totalXp
        gigaPowerCounter.numberOfGigaPowers = viewModel.numberOfPokemonsWithGigaPower
        if viewModel.isDisabled {
            checkbox.shouldDisable = true
        } else {
            checkbox.shouldDisable = false
        }
        print("DEBUG: checkbox isChecked=\(viewModel.hasSelectedPokemon)")
        checkbox.isChecked = viewModel.hasSelectedPokemon
    }
    
    // MARK: - API

}
