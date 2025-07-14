import UIKit

class FinishedViewController: UIViewController {
    private var articles: [Article] = []
    private let tableView = UITableView()
    private let bottomBar = BottomNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Finished Reading"
        view.addSubviews(tableView, bottomBar)
        setupBottomBar() // Moved before setupTableView
        setupTableView()
        loadFinishedArticles()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "ArticleCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
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
    
    private func loadFinishedArticles() {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            showEmptyState()
            return
        }
        articles = ArticleManager.getArticles(forIDs: userData.completedArticleIDs)
        tableView.reloadData()
        
        if articles.isEmpty {
            showEmptyState()
        }
        updateResumeReadingButton()
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "You don't have any completed articles"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.numberOfLines = 0
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
    
    private func removeArticle(at index: Int) {
        let articleId = articles[index].id
        articles.remove(at: index)
        
        if let userData = SwiftDataManager.shared.getUserData(),
           let indexToRemove = userData.completedArticleIDs.firstIndex(of: articleId) {
            userData.completedArticleIDs.remove(at: indexToRemove)
            SwiftDataManager.shared.save()
        }
        
        tableView.reloadData()
        
        if articles.isEmpty {
            showEmptyState()
        }
    }
    
    private func showDeleteConfirmation(forArticleAt index: Int) {
        let article = articles[index]
        let alert = UIAlertController(
            title: "Remove Article",
            message: "Are you sure you want to remove \"\(article.title)\" from finished articles?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeArticle(at: index)
        })
        
        present(alert, animated: true)
    }
}

extension FinishedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        cell.configure(with: articles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteConfirmation(forArticleAt: indexPath.row)
        }
    }
}

extension FinishedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedArticle = articles[indexPath.row]
        let detailVC = ArticleViewController(article: selectedArticle)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
}
