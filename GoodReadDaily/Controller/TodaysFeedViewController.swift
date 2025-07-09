//
//  TodaysFeedViewController.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import UIKit

final class TodaysFeedViewController: UIViewController {
    private var articles: [Article] = []
    private let tableView = UITableView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Today's Feed"
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArticleCell")
        
        tableView.delegate = self
    }
    
    private func loadUserArticles() {
        if ArticleStorage.shouldRefreshArticles() {
            refreshArticles()
        }
        else if let storedArticles = ArticleStorage.getTodaysArticles() {
            articles = storedArticles
            tableView.reloadData()
        }
        else {
            refreshArticles()
        }
    }
    
    @objc private func refreshArticles() {
        let genres = UserDataManager.shared.userData.preferences.genres
        let newArticles = ArticleManager.getRandomArticles(for: genres, count: 3)
        
        ArticleStorage.storeTodaysArticles(newArticles)
        articles = newArticles
        
        tableView.reloadData()
        if newArticles.isEmpty {
            showEmptyState()
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No articles found for your selected genres"
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.textColor = .gray
        
        tableView.backgroundView = emptyLabel
    }
}

extension TodaysFeedViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return articles.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ArticleCell",
            for: indexPath
        )
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
        let detailVC = ArticleViewController(article: selectedArticle)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
