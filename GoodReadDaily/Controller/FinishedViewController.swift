import UIKit

class FinishedViewController: UIViewController {
    private var articles: [Article] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Finished Reading"
        setupTableView()
        loadFinishedArticles()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArticleCell")
    }
    
    private func loadFinishedArticles() {
        let CompletedIDs = UserDataManager.shared.userData.completedArticleIDs
        articles = ArticleManager.loadArticles().filter { CompletedIDs.contains($0.id)
        }
        tableView.reloadData()
        
        if articles.isEmpty {
            showEmptyState()
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "You don't have any completed articles"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.numberOfLines = 0
        
        tableView.backgroundView = emptyLabel
    }
}

extension FinishedViewController: UITableViewDataSource {
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

extension FinishedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedArticle = articles[indexPath.row]
        let detailVC = ArticleViewController(article: selectedArticle)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
