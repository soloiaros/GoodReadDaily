import UIKit

class InProcessViewController: UIViewController {
    private var articles: [Article] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Currently Reading"
        setupTableView()
        loadInProgressArticles()
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
    
    private func loadInProgressArticles() {
        let inProgressIDs = UserDataManager.shared.userData.inProgressArticleIDs
        articles = ArticleManager.loadArticles().filter { article in
            inProgressIDs.contains(article.id)
        }
        articles = articles.filter { !UserDataManager.shared.userData.completedArticleIDs.contains($0.id)
        }
        tableView.reloadData()
        
        if articles.isEmpty {
            showEmptyState()
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "You don't have any articles in progress"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.numberOfLines = 0
        
        tableView.backgroundView = emptyLabel
    }
}

class ArticleTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Настройка контейнера
        contentView.backgroundColor = UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 1.0)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        // Настройка заголовка
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Настройка подзаголовка
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .darkGray
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Стек для текстовых элементов
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        
        contentView.addSubview(textStack)
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        subtitleLabel.text = article.subtitle
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Отступы между ячейками
        let margins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
}

extension InProcessViewController: UITableViewDataSource {
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
}

extension InProcessViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedArticle = articles[indexPath.row]
        let detailVC = ArticleViewController(article: selectedArticle)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
