import UIKit
import FirebaseAuth

class GenreSelectionViewController: UIViewController {
    private let genresTableView = UITableView()
    private var genres: [String] = ["Science", "Technology", "Fashion", "History", "Architecture", "Celebrities", "Travel", "Food", "Art", "Literature"]
    private var selectedGenres: [String] = []
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Genres", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let welcomeLabel : UILabel = {
        let label = UILabel()
        label.text = "Welcome! Select genres to personalize your feed."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select Genres"
        setupUI()
        setupActions()
        loadUserData()
        print("GenreSelectionViewController: viewDidLoad completed, tableView added: \(genresTableView.superview != nil)")
    }
    
    private func setupUI() {
       
        view.addSubviews(welcomeLabel, genresTableView, saveButton)
        
        genresTableView.dataSource = self
        genresTableView.delegate = self
        genresTableView.register(UITableViewCell.self, forCellReuseIdentifier: "GenreCell")
        genresTableView.rowHeight = UITableView.automaticDimension
        genresTableView.estimatedRowHeight = 44
        genresTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            genresTableView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 16),
            genresTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            genresTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            genresTableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveGenres), for: .touchUpInside)
    }
    
    private func loadUserData() {
        if let userData = SwiftDataManager.shared.getUserData() {
            selectedGenres = userData.preferences.genres
            genresTableView.reloadData()
            print("GenreSelectionViewController: Loaded genres: \(selectedGenres), hasSeenGenreScreen: \(userData.preferences.hasSeenGenreScreen)")
        } else {
            print("GenreSelectionViewController: No userData found")
        }
    }
    
    @objc private func saveGenres() {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            print("GenreSelectionViewController: No userData to save genres")
            return
        }
        userData.preferences.genres = selectedGenres
        userData.preferences.hasSeenGenreScreen = true
        SwiftDataManager.shared.save()
        print("GenreSelectionViewController: Saved genres: \(selectedGenres), hasSeenGenreScreen: true")
        navigationController?.setViewControllers([MainViewController()], animated: true)
    }
}

extension GenreSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = genres.count
        print("GenreSelectionViewController: Table view rows: \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath)
        let genre = genres[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = genre
        config.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        config.textProperties.color = .label
        cell.contentConfiguration = config
        cell.accessoryType = selectedGenres.contains(genre) ? .checkmark : .none
        cell.selectionStyle = .default
        cell.backgroundColor = .systemBackground
        print("GenreSelectionViewController: Configured cell for genre: \(genre)")
        return cell
    }
}

extension GenreSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let genre = genres[indexPath.row]
        if selectedGenres.contains(genre) {
            selectedGenres.removeAll { $0 == genre }
        } else {
            selectedGenres.append(genre)
        }
        tableView.reloadData()
        print("GenreSelectionViewController: Toggled genre: \(genre), new selection: \(selectedGenres)")
    }
}
