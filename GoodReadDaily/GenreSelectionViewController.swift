//
//  GenreSelectionViewController.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import UIKit

class GenreSelectionViewController: UIViewController {
    let genres = ["Science", "Technology", "Fashion", "Politics"]
    var selectedGenres = Set<String>()
    
    let doneButton = UIButton(type: .system)
    let genreButtons: [GenreSelectButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Choose Your Genres"
        setupUI()
    }

    func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for genre in genres {
            let button = UIButton(type: .system)
            button.setTitle(genre, for: .normal)
            button.tag = genres.firstIndex(of: genre)!
            button.addTarget(self, action: #selector(toggleGenre(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        doneButton.setTitle("Continue", for: .normal)
        doneButton.addTarget(self, action: #selector(finishOnboarding), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        view.addSubview(doneButton)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20).isActive = true
        doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(stack)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.widthAnchor.constraint(equalToConstant: 280),

            doneButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 30),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func toggleGenre(_ sender: GenreSelectButton) {
        sender.isSelected.toggle()
        guard let genre = sender.title(for: .normal) else { return }
        if sender.isSelected {
            selectedGenres.insert(genre)
        } else {
            selectedGenres.remove(genre)
        }
    }

    @objc func finishOnboarding() {
        var userData = UserDataManager.shared.userData
        userData.preferences.genres = Array(selectedGenres)
        userData.preferences.hasSeenGenreScreen = true
        UserDataManager.shared.userData = userData
        UserDataManager.shared.save()

        let mainVC = MainViewController()
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true)
    }
}


class GenreSelectButton: UIButton {
    private let checkmark = UIImageView()
    
    override var isSelected: Bool {
        didSet {
            updateStyle()
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        setTitleColor(.black, for: .normal)
        contentHorizontalAlignment = .left
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)

        checkmark.image = UIImage(systemName: "checkmark.circle.fill")
        checkmark.tintColor = .systemBlue
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        addSubview(checkmark)

        NSLayoutConstraint.activate([
            checkmark.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmark.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            checkmark.widthAnchor.constraint(equalToConstant: 20),
            checkmark.heightAnchor.constraint(equalToConstant: 20)
        ])

        updateStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateStyle() {
        backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : .white
        layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.gray.cgColor
        checkmark.isHidden = !isSelected
    }
}
