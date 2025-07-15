import UIKit

class InProcessViewController: UIViewController {
    private var articles: [Article] = []
    private let tableView = UITableView()
    private let bottomBar = BottomNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Currently Reading"
        setupBottomBar() // Moved before setupTableView
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
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
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
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 100)
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
    
    private func loadInProgressArticles() {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            showEmptyState()
            return
        }
        articles = ArticleManager.getArticles(forIDs: userData.inProgressArticleIDs)
        articles = articles.filter { !userData.completedArticleIDs.contains($0.id) }
        tableView.reloadData()
        
        if articles.isEmpty {
            showEmptyState()
        }
        updateResumeReadingButton()
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "You don't have any articles in progress"
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
}

class ArticleTableViewCell: UITableViewCell {
    private let containerView = UIView()
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
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        // Настройка контейнера с тенью
        containerView.backgroundColor = UIColor.systemBrown.withAlphaComponent(0.1)  // Changed this line
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = false
        
        // Настройка тени
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        // Настройка текста
//        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .darkGray
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        
        // Вертикальный стек для текста
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        
        containerView.addSubview(textStack)
        contentView.addSubview(containerView)
        
        // Устанавливаем констрейнты
        textStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Контейнер с отступами 8pt сверху/снизу и 0 по бокам
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Текст с отступами 12pt сверху/снизу и 16pt по бокам
            textStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        subtitleLabel.text = article.subtitle
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        UIView.animate(withDuration: 0.2) {
//            self.containerView.backgroundColor = selected ?
//                UIColor(red: 0.92, green: 0.90, blue: 0.85, alpha: 1.0) :
//                UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 1.0)
//        }
//    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            // Изменяем цвет при нажатии на более темный вариант
            self.containerView.backgroundColor = highlighted ?
                UIColor.systemBrown.withAlphaComponent(0.2) :  // Slightly more opaque when highlighted
                UIColor.systemBrown.withAlphaComponent(0.1)
        }
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
