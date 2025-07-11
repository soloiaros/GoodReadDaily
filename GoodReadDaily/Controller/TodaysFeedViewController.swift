import UIKit

final class TodaysFeedViewController: UIViewController {
    private var articles: [Article] = []
    private let tableView = UITableView(frame: .zero)
    private let bottomBar = BottomNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Today's Feed"
        setupBottomBar() // Moved before setupTableView
        setupTableView()
        loadUserArticles()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArticleCell")
        tableView.delegate = self
    }
    
    private func setupBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        bottomBar.onMainTapped = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        bottomBar.onResumeReadingTapped = { [weak self] in
            self?.navigateToResumeReading()
        }
        bottomBar.onSettingsTapped = { [weak self] in
            self?.navigationController?.pushViewController(SettingsViewController(), animated: true)
        }
        
        updateResumeReadingButton()
    }
    
    private func loadUserArticles() {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            showEmptyState()
            return
        }
        // Load articles from todaysArticleIDs if available and no refresh needed
        if !ArticleStorage.shouldRefreshArticles(), !userData.todaysArticleIDs.isEmpty {
            articles = ArticleManager.getArticles(forIDs: userData.todaysArticleIDs)
            tableView.reloadData()
            if articles.isEmpty {
                refreshArticles() // Fallback if IDs don't match any articles
            } else {
                tableView.backgroundView = nil
            }
        } else {
            refreshArticles()
        }
        updateResumeReadingButton()
    }
    
    @objc private func refreshArticles() {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            showEmptyState()
            return
        }
        let genres = userData.preferences.genres
        let newArticles = ArticleManager.getRandomArticles(for: genres, count: 3)
        
        userData.todaysArticleIDs = newArticles.map { $0.id }
        userData.lastRefreshDate = Date()
        SwiftDataManager.shared.save()
        articles = newArticles
        
        tableView.reloadData()
        if newArticles.isEmpty {
            showEmptyState()
        } else {
            tableView.backgroundView = nil
        }
        updateResumeReadingButton()
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No articles found for your selected genres"
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.textColor = .gray
        tableView.backgroundView = emptyLabel
    }
    
    private func updateResumeReadingButton() {
        if let userData = SwiftDataManager.shared.getUserData() {
            bottomBar.updateResumeReadingButton(isEnabled: !userData.inProgressArticleIDs.isEmpty)
        }
    }
    
    private func navigateToResumeReading() {
        guard let userData = SwiftDataManager.shared.getUserData(),
              let lastArticleID = userData.inProgressArticleIDs.last,
              let article = ArticleManager.getArticles(forIDs: [lastArticleID]).first else {
            return
        }
        let detailVC = ArticleViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TodaysFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        let article = articles[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = article.title
        config.secondaryText = article.subtitle
        cell.contentConfiguration = config
        return cell
    }
}

extension TodaysFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedArticle = articles[indexPath.row]
        let selectedArticleID = selectedArticle.id
        if let userData = SwiftDataManager.shared.getUserData(),
           !userData.inProgressArticleIDs.contains(selectedArticleID) {
            userData.inProgressArticleIDs.append(selectedArticleID)
            SwiftDataManager.shared.save()
        }
        let detailVC = ArticleViewController(article: selectedArticle)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
