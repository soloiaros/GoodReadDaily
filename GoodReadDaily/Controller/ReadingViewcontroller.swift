import UIKit

final class ArticleViewController: UIViewController {
    private let article: Article
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let authorLabel = UILabel()
    private let genreLabel = UILabel()
    private let idLabel = UILabel()
    private let contentLabel = UILabel()
    private let readButton = UIButton(type: .system)
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        configure(with: article)
    }
    
    private func setupUI() {
        // ScrollView setup
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.font = UIFont.italicSystemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        contentView.addSubview(subtitleLabel)
        
        // Author Label
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .darkGray
        contentView.addSubview(authorLabel)
        
        // Genre Label
        genreLabel.font = UIFont.systemFont(ofSize: 14)
        genreLabel.textColor = .darkGray
        contentView.addSubview(genreLabel)
        
        // ID Label
        idLabel.font = UIFont.systemFont(ofSize: 12)
        idLabel.textColor = .lightGray
        contentView.addSubview(idLabel)
        
        // Content Label
        contentLabel.font = UIFont.systemFont(ofSize: 18)
        contentLabel.numberOfLines = 0
        contentView.addSubview(contentLabel)
        
        // Read Button
        readButton.setTitle("Mark as read", for: .normal)
        readButton.backgroundColor = .systemBlue
        readButton.setTitleColor(.white, for: .normal)
        readButton.layer.cornerRadius = 8
        readButton.addTarget(self, action: #selector(readButtonTapped), for: .touchUpInside)
        contentView.addSubview(readButton)
        
        // Constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        readButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            genreLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            idLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 4),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            readButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
            readButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            readButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            readButton.heightAnchor.constraint(equalToConstant: 44),
            readButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func configure(with article: Article) {
        title = article.title
        titleLabel.text = article.title
        subtitleLabel.text = article.subtitle
        authorLabel.text = "By \(article.author)"
        genreLabel.text = "#\(article.genre)"
        idLabel.text = "ID: \(article.id)"
        contentLabel.text = article.content
    }
    
    @objc private func readButtonTapped() {
        // Здесь можно добавить логику отметки статьи как прочитанной
        print("Статья \(article.id) отмечена как прочитанная")
        
        // Визуальная обратная связь
        readButton.setTitle("✓ Read", for: .normal)
        readButton.backgroundColor = .systemGreen
        
        // Можно добавить анимацию
        UIView.animate(withDuration: 0.3, animations: {
            self.readButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.readButton.transform = .identity
            }
        }
        
        
        
    }
}
