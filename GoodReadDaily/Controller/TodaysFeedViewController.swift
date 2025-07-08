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
    }
    
    private func loadUserArticles() {
        let genres = UserDataManager.shared.userData.preferences.genres
        print("User's genres: \(genres)")
        let loadedArticles = ArticleManager.getRandomArticles(for: genres, count: 3)
        articles = loadedArticles
        print("Loaded articles: \(articles)")
        tableView.reloadData()
        
        if loadedArticles.isEmpty {
            showEmptyState()
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
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = article.subtitle
        return cell
    }
}

