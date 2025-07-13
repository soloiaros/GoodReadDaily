import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let avatarImageView = UIImageView()
    private let loginLabel = UILabel()
    private let genresTableView = UITableView()
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update My Preferences", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var genres: [String] = ["Science", "Technology", "Fashion", "History", "Architecture", "Celebrities", "Travel", "Food", "Art", "Literature"]
    private var selectedGenres: [String] = []
    private let bottomBar = BottomNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        navigationItem.hidesBackButton = true
        setupBottomBar()
        setupUI()
        setupActions()
        loadUserData()
        print("SettingsViewController: viewDidLoad completed, tableView added: \(genresTableView.superview != nil)")
    }
    
    private func setupUI() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Avatar Image
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)
        
        // Login Label
        loginLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        loginLabel.textAlignment = .center
        loginLabel.numberOfLines = 0
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loginLabel)
        
        // Genres Table View
        genresTableView.dataSource = self
        genresTableView.delegate = self
        genresTableView.register(UITableViewCell.self, forCellReuseIdentifier: "GenreCell")
        genresTableView.rowHeight = UITableView.automaticDimension
        genresTableView.estimatedRowHeight = 44
        genresTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genresTableView)
        
        // Update Button
        contentView.addSubview(updateButton)
        
        // Logout Button
        contentView.addSubview(logoutButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            loginLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            loginLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loginLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            genresTableView.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 20),
            genresTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genresTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            genresTableView.heightAnchor.constraint(equalToConstant: 264), // 6 genres * 44px
            
            updateButton.topAnchor.constraint(equalTo: genresTableView.bottomAnchor, constant: 16),
            updateButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            updateButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoutButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 16),
            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        bottomBar.updateSettingsButtonColor(true)
        
        bottomBar.onMainTapped = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        bottomBar.onResumeReadingTapped = { [weak self] in
            self?.navigateToResumeReading()
        }
//        bottomBar.onSettingsTapped = { [weak self] in
//            // Already on Settings, no action needed
//        }
        
        updateResumeReadingButton()
    }
    
    private func setupActions() {
        updateButton.addTarget(self, action: #selector(updatePreferences), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
    }
    
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else {
            loginLabel.text = "Not logged in"
            selectedGenres = []
            genresTableView.reloadData()
            print("SettingsViewController: No user logged in")
            return
        }
        loginLabel.text = user.email ?? "Unknown User"
        
        if let userData = SwiftDataManager.shared.getUserData() {
            selectedGenres = userData.preferences.genres
            genresTableView.reloadData()
            updateResumeReadingButton()
            print("SettingsViewController: Loaded genres: \(selectedGenres)")
        } else {
            selectedGenres = []
            genresTableView.reloadData()
            print("SettingsViewController: Failed to load userData")
        }
    }
    
    private func updateResumeReadingButton() {
        if let userData = SwiftDataManager.shared.getUserData() {
            bottomBar.updateResumeReadingButton(isEnabled: !userData.inProgressArticleIDs.isEmpty)
            print("SettingsViewController: Resume Reading enabled: \(!userData.inProgressArticleIDs.isEmpty)")
        }
    }
    
    private func navigateToResumeReading() {
        guard let userData = SwiftDataManager.shared.getUserData(),
              let lastArticleID = userData.inProgressArticleIDs.last,
              let article = ArticleManager.getArticles(forIDs: [lastArticleID]).first else {
            print("SettingsViewController: No articles to resume")
            return
        }
        let detailVC = ArticleViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
        print("SettingsViewController: Navigated to article ID: \(lastArticleID)")
    }
    
    @objc private func updatePreferences() {
        if let userData = SwiftDataManager.shared.getUserData() {
            userData.preferences.genres = selectedGenres
            SwiftDataManager.shared.save()
            print("SettingsViewController: Saved genres: \(selectedGenres)")
            navigationController?.popToRootViewController(animated: true)
        } else {
            print("SettingsViewController: Failed to save preferences, no userData")
        }
    }
    
    @objc private func handleLogout() {
        do {
            try Auth.auth().signOut()
            let loginVC = LoginViewController()
            let navVC = UINavigationController(rootViewController: loginVC)
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = navVC
            }
            print("SettingsViewController: Logged out successfully")
        } catch let signOutError as NSError {
            print("SettingsViewController: Error signing out: \(signOutError)")
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = genres.count
        print("SettingsViewController: Table view rows: \(count)")
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
        print("SettingsViewController: Configured cell for genre: \(genre), selected: \(selectedGenres.contains(genre))")
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let genre = genres[indexPath.row]
        if selectedGenres.contains(genre) {
            selectedGenres.removeAll { $0 == genre }
        } else {
            selectedGenres.append(genre)
        }
        tableView.reloadData()
        print("SettingsViewController: Toggled genre: \(genre), new selection: \(selectedGenres)")
    }
}
