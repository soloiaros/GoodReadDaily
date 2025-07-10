import UIKit

final class ArticleViewController: UIViewController {
    private let article: Article
    
    private let articlecolour = UIColor(red: 235, green: 226, blue: 197, alpha: 1.0)

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
        view.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 220/255, alpha: 1.0)
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
        titleLabel.font = mont_med
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.font = mont_it_big
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        contentView.addSubview(subtitleLabel)
    
        
        // ID Label
        idLabel.font = Ofont
        idLabel.textColor = .lightGray
        contentView.addSubview(idLabel)
        
        // Content Label
        contentLabel.font = tinos_reg
        contentLabel.numberOfLines = 0
        contentView.addSubview(contentLabel)
        
        // Author Label
        authorLabel.font = mont_light
        authorLabel.textColor = .darkGray
        authorLabel.textAlignment = .right
        contentView.addSubview(authorLabel)
        
        // Genre Label
        genreLabel.font = mont_light
        genreLabel.textColor = .darkGray
        genreLabel.textAlignment = .right
        contentView.addSubview(genreLabel)
        
        // Read Button
        var color = UIColor.systemBlue
        var title = "Mark as read"
//        let articleID = article.id
//        if !UserDataManager.shared.userData.completedArticleIDs.contains(articleID) {
//            title = "✓ Read"
//            color = UIColor.systemGreen
//            return
//        }
        readButton.backgroundColor = UIColor(red: 191/255, green: 155/255, blue: 132/255, alpha: 0.51)
        readButton.setTitle(title, for: .normal)
        readButton.setTitleColor(.white, for: .normal)
        readButton.layer.cornerRadius = 15
        readButton.addTarget(self, action: #selector(readButtonTapped), for: .touchUpInside)

        readButton.layer.shadowColor = UIColor.black.cgColor
        readButton.layer.shadowOpacity = 0.21
        readButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        readButton.layer.shadowRadius = 4
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
            
            idLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 0),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
            
            genreLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
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

        // Визуальная обратная связь
        readButton.setTitle("✓ Read", for: .normal)
        readButton.backgroundColor = UIColor(red: 89/255, green: 101/255, blue: 123/255, alpha: 1.0)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.readButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.readButton.transform = .identity
            }
        }
        
        let articleID = article.id
        if UserDataManager.shared.userData.completedArticleIDs.contains(articleID) {
            
            showAlreadyReadAlert()
            return
        }
        else {
            UserDataManager.shared.userData.completedArticleIDs.append(articleID)
            return
        }
        
    }
        
    private func showAlreadyReadAlert() {
        let alert = UIAlertController(
            title: "This article is already read",
            message: "You have marked this article as read before. No need to mark it again!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
        
}
