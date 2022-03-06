//
//  EnterTeamDetailsController.swift
//  Pokemon Dictionary
//
//  Created by Joel Kingsley on 08/09/21.
//

import UIKit
import CoreData

protocol EnterTeamDetailsControllerDelegate: AnyObject {
    func wantsToCreateTeam(_ team: FirestoreTeam, with pokemons: [FirestorePokemon])
}

class EnterTeamDetailsController: UIViewController {
    // MARK: - Properties
    
    private var viewModel = EnterTeamDetailsViewModel()
    
    private let newTeamLabel: UILabel = {
        let label = UILabel()
        label.text = "New Team"
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
    
    private lazy var createButton: CustomTextButton = {
        let button = CustomTextButton()
        button.setLinkStyleAttributedTitle(text: "Create")
        button.isEnabled = false
        button.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .disabled)
        button.addTarget(self, action: #selector(handleCreateButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var profileImagePicker: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-cat-profile-100"), for: .normal)
        return button
    }()
    
    private lazy var nameTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.borderStyle = UITextField.BorderStyle.roundedRect
        tf.textColor = .black
        tf.keyboardAppearance = .dark
        tf.keyboardType = .default
        tf.backgroundColor = UIColor(white: 1, alpha: 0.1)
        tf.heightAnchor.constraint(equalToConstant: CGFloat(50)).isActive = true
        tf.attributedPlaceholder = NSAttributedString(string: "Team Name", attributes: [.foregroundColor: UIColor.lightGray])
        return tf
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please provide a team name and optional team profile image"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    weak var delegate: EnterTeamDetailsControllerDelegate?
    
    var selectedPokemons = [FirestorePokemon]()
    
    // MARK: - Lifecycle
    
    init(selectedPokemons: [FirestorePokemon]) {
        self.selectedPokemons = selectedPokemons
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: - Actions
    
    @objc func handleCancelButtonClicked() {
        print("DEBUG: Cancel button clicked")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCreateButtonClicked() {
        print("DEBUG: Create button clicked")
        guard let teamName = viewModel.teamName else { return }
        let teamProfileImageUrl = viewModel.teamProfileImageUrl ?? ""
        
        let firestorePokemons = selectedPokemons
        var pokemonsWithGigaPower = firestorePokemons
        pokemonsWithGigaPower.removeAll(where: { $0.hasGigaPower == false })
        
        let team = FirestoreTeam(name: teamName, profileImageUrl: teamProfileImageUrl, totalXp: (firestorePokemons.map({ $0.xp }).reduce(0, +)), numberOfPokemonsWithGigaPower: pokemonsWithGigaPower.count)
        delegate?.wantsToCreateTeam(team, with: firestorePokemons)
    }
    
    @objc func textDidChange() {
        viewModel.teamName = nameTextField.text
        
        updateForm()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        createButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(newTeamLabel)
        newTeamLabel.translatesAutoresizingMaskIntoConstraints = false
        newTeamLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        newTeamLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newTeamLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(profileImagePicker)
        profileImagePicker.translatesAutoresizingMaskIntoConstraints = false
        profileImagePicker.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        profileImagePicker.topAnchor.constraint(equalTo: newTeamLabel.bottomAnchor, constant: 20).isActive = true
        profileImagePicker.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImagePicker.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.leftAnchor.constraint(equalTo: profileImagePicker.rightAnchor, constant: 10).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        nameTextField.topAnchor.constraint(equalTo: newTeamLabel.bottomAnchor, constant: 20).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(instructionLabel)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.leftAnchor.constraint(equalTo: nameTextField.leftAnchor).isActive = true
        instructionLabel.rightAnchor.constraint(equalTo: nameTextField.rightAnchor).isActive = true
        instructionLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10).isActive = true
    }
    
    func configureNotificationObservers() {
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func updateForm() {
        createButton.isEnabled = viewModel.formIsValid
        if viewModel.formIsValid {
            createButton.setTitleColor(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), for: .normal)
        } else {
            createButton.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .disabled)
        }
    }
    
    // MARK: - API
}
