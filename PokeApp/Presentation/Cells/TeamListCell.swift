//
//  TeamListCell.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 14/09/21.
//

import UIKit
import SDWebImage

class TeamListCell: UICollectionViewCell {
    
    public static let reuseIdentifier = "TeamListCell"
    
    // MARK: - Properties
    
    var viewModel: TeamListItemViewModel? {
        didSet {
            configure()
        }
    }
    
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
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 20).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, placeholderImage: #imageLiteral(resourceName: "icons8-cat-profile-100"), options: SDWebImageOptions(), completed: nil)
        nameLabel.text = viewModel.teamName
        totalXpLabel.text = viewModel.totalXp
        gigaPowerCounter.numberOfGigaPowers = viewModel.numberOfPokemonsWithGigaPower
    }
}
