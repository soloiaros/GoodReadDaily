
import UIKit

class GenreSelectionViewController: UIViewController {
    let genres = ["Science", "Technology", "Fashion", "History", "Architecture", "Celebrities", "Travel", "Food", "Art", "Literature"]
    var selectedGenres = Set<String>() {
        didSet {
            updateCounterLabel()
        }
    }
    
    let doneButton = UIButton(type: .system)
    let skipButton = UIButton(type: .system)
    let genreButtons: [GenreSelectButton] = []
    let maxGenreSelection = 5
    var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Choose Your Genres"
        setupNavigationCounter()
        setupUI()
    }
    
    func setupNavigationCounter() {
        counterLabel = UILabel()
        counterLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        counterLabel.textColor = .secondaryLabel
        updateCounterLabel()
        
        let counterItem = UIBarButtonItem(customView: counterLabel)
        navigationItem.rightBarButtonItem = counterItem
    }
    
    func updateCounterLabel() {
        let remaining = maxGenreSelection - selectedGenres.count
        counterLabel.text = "Choose \(remaining) more \(remaining == 1 ? "genre" : "genres")!"
        counterLabel.sizeToFit()
    }
    
    func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for genre in genres {
            let button = GenreSelectButton(title: genre)
            button.tag = genres.firstIndex(of: genre)!
            button.addTarget(self, action: #selector(toggleGenre(_:)), for: .touchUpInside)
            button.setTitle(genre, for: .normal)
            stack.addArrangedSubview(button)
        }
        
        doneButton.setTitle("Continue", for: .normal)
        doneButton.addTarget(self, action: #selector(finishOnboarding), for: .touchUpInside)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.gray, for: .normal)
        skipButton.addTarget(self, action: #selector(skipOnboarding), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [doneButton, skipButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.widthAnchor.constraint(equalToConstant: 280),
            
            buttonStack.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 30),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func skipOnboarding() {
        proceedWithOnboarding(genres: [])
    }
    
    @objc func toggleGenre(_ sender: GenreSelectButton) {
        guard let genre = sender.title(for: .normal) else { return }
        
        if sender.isSelected {
            selectedGenres.remove(genre.lowercased())
            sender.isSelected = false
        } else {
            if selectedGenres.count < maxGenreSelection {
                selectedGenres.insert(genre.lowercased())
                sender.isSelected = true
            } else {
                let alert = UIAlertController(
                    title: "Maximum Reached",
                    message: "You can select up to \(maxGenreSelection) genres.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    @objc func finishOnboarding() {
        guard selectedGenres.count <= maxGenreSelection else {
            showValidationAlert(message: "You can only select \(maxGenreSelection) genres.")
            return
        }
        
        proceedWithOnboarding(genres: Array(selectedGenres))
    }
    
    private func proceedWithOnboarding(genres: [String]) {
        if let userData = SwiftDataManager.shared.getUserData() {
            userData.preferences.genres = genres
            userData.preferences.hasSeenGenreScreen = true
            SwiftDataManager.shared.save()
            
            let todaysArticles = ArticleManager.getRandomArticles(for: genres, count: 3)
            ArticleStorage.storeTodaysArticles(todaysArticles)
            
            let mainVC = MainViewController()
            let navController = UINavigationController(rootViewController: mainVC)
            guard let window = view.window ?? UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first else { return }
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navController
            }, completion: nil)
        }
    }
    
    private func showValidationAlert(message: String) {
        let alert = UIAlertController(
            title: "Selection required",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
