import UIKit
import FirebaseAuth

class MainViewController: UIViewController {
    
    private let todaysFeedButton = MainWidgetButton(
        title: "Today's Feed",
        subtitle: "Your 3 fresh articles are ready!",
        isLarge: true,
        backgroundColor: UIColor(red: 160/255.0, green: 134/255.0, blue: 121/255.0, alpha: 0.5)
    )
    
    private let inProcessButton = MainWidgetButton(
        title: "In Process",
        subtitle: "Continue reading"
    )
    
    private let dictionaryButton = MainWidgetButton(
        title: "Dictionary",
        subtitle: "Words you saved"
    )
    
    private let finishedArticlesButton = MainWidgetButton(
        title: "Finished Articles",
        subtitle: "View your completed readings"
    )
    
    private let bottomBar = BottomNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
        title = "GoodReadDaily"
        view.backgroundColor = .systemGroupedBackground
        setupBottomBar()
        setupLayout()
        setupActions()
        viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [todaysFeedButton, inProcessButton, dictionaryButton, finishedArticlesButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomBar.topAnchor, constant: -16)
        ])
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
            // Already on MainViewController, no action needed
        }
        bottomBar.onResumeReadingTapped = { [weak self] in
            self?.navigateToResumeReading()
        }
        bottomBar.onSettingsTapped = { [weak self] in
            self?.navigationController?.pushViewController(SettingsViewController(), animated: true)
        }
        
        updateResumeReadingButton()
    }
    
    private func setupActions() {
        todaysFeedButton.addTarget(self, action: #selector(openTodaysFeed), for: .touchUpInside)
        inProcessButton.addTarget(self, action: #selector(openInProcess), for: .touchUpInside)
        dictionaryButton.addTarget(self, action: #selector(openDictionary), for: .touchUpInside)
        finishedArticlesButton.addTarget(self, action: #selector(openFinishedArticles), for: .touchUpInside)
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
    
    @objc private func openTodaysFeed() {
        let vc = TodaysFeedViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openInProcess() {
        let vc = InProcessViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openDictionary() {
        let vc = DictionaryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openFinishedArticles() {
        print("Finished articles btn")
        let vc = FinishedViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

class MainWidgetButton: UIControl {
    
    private let titleLabelView = UILabel()
    private let subtitleLabelView = UILabel()
    private let contentStack = UIStackView()
    
    init(title: String, subtitle: String, isLarge: Bool = false, backgroundColor: UIColor = UIColor.systemBrown.withAlphaComponent(0.1)) {
        super.init(frame: .zero)
        setupUI(title: title, subtitle: subtitle, isLarge: isLarge, backgroundColor: backgroundColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, subtitle: String, isLarge: Bool, backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 12
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        translatesAutoresizingMaskIntoConstraints = false
        
        titleLabelView.text = title
        titleLabelView.font = UIFont.systemFont(ofSize: isLarge ? 22 : 18, weight: .bold)
        titleLabelView.textColor = .label
        titleLabelView.numberOfLines = 0
        titleLabelView.isUserInteractionEnabled = false
        
        subtitleLabelView.text = subtitle
        subtitleLabelView.font = UIFont.systemFont(ofSize: isLarge ? 16 : 14)
        subtitleLabelView.textColor = .darkGray
        subtitleLabelView.numberOfLines = 0
        subtitleLabelView.isUserInteractionEnabled = false
        
        contentStack.axis = .vertical
        contentStack.spacing = 6
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isUserInteractionEnabled = false
        contentStack.addArrangedSubview(titleLabelView)
        contentStack.addArrangedSubview(subtitleLabelView)
        
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: isLarge ? 120 : 80),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1.0
        }
    }
}
