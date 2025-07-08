//
//  ViewController.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/4/25.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {
    
    private let todaysFeedButton = MainWidgetButton(
        title: "Today's Feed",
        subtitle: "Your 3 fresh articles are ready!",
        isLarge: true,
    )
    
    private let inProcessButton = MainWidgetButton(
        title: "In Process",
        subtitle: "Continue reading",
    )
    
    private let dictionaryButton = MainWidgetButton(
        title: "Dictionary",
        subtitle: "Words you saved",
    )
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(navigationController != nil)
        title = "GoodReadDaily"
        view.backgroundColor = .white
        setupLayout()
        setupActions()
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [todaysFeedButton, inProcessButton, dictionaryButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setupActions() {
        todaysFeedButton.addTarget(self, action: #selector(openTodaysFeed), for: .touchUpInside)
        inProcessButton.addTarget(self, action: #selector(openInProcess), for: .touchUpInside)
        dictionaryButton.addTarget(self, action: #selector(openDictionary), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
    }

    @objc private func openTodaysFeed() {
        print("Feed btn")
        let vc = TodaysFeedViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openInProcess() {
        print("process btn")
        let vc = InProcessViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openDictionary() {
        print("Dictionary btn")
        let vc = DictionaryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleLogout() {
        do {
            try Auth.auth().signOut()
            
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
            print(UserDefaults.standard.dictionaryRepresentation())
            
            let loginVC = LoginViewController()
            let navVC = UINavigationController(rootViewController: loginVC)
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = navVC
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

class MainWidgetButton: UIControl {
    
    private let titleLabelView = UILabel()
    private let subtitleLabelView = UILabel()
    private let contentStack = UIStackView()

    init(title: String, subtitle: String, isLarge: Bool = false) {
        super.init(frame: .zero)
        setupUI(title: title, subtitle: subtitle, isLarge: isLarge)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(title: String, subtitle: String, isLarge: Bool) {
        backgroundColor = UIColor.systemBrown.withAlphaComponent(0.1)
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        titleLabelView.text = title
        titleLabelView.font = UIFont.systemFont(ofSize: isLarge ? 22 : 18, weight: .bold)
        titleLabelView.textColor = .label
        titleLabelView.numberOfLines = 0
        titleLabelView.isUserInteractionEnabled = false // Add this
        
        // Subtitle
        subtitleLabelView.text = subtitle
        subtitleLabelView.font = UIFont.systemFont(ofSize: isLarge ? 16 : 14)
        subtitleLabelView.textColor = .darkGray
        subtitleLabelView.numberOfLines = 0
        subtitleLabelView.isUserInteractionEnabled = false // Add this
        
        // Stack
        contentStack.axis = .vertical
        contentStack.spacing = 6
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isUserInteractionEnabled = false // Add this
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
