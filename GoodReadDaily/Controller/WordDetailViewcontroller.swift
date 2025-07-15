//
//  WordDetailViewcontroller.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/9/25.
//

import UIKit

class WordDetailViewController: UIViewController {
    
    private let word: String
    private let context: String?
    private var apiResponses: [FreeDictionaryResponse] = []
    private let apiService = DictionaryAPIService()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(word: String, context: String? = nil) {
        self.word = word
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = word.capitalized
        setupViews()
        fetchWordDetails()
    }
    
    private func setupViews() {
        setupScrollView()
        setupActivityIndicator()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchWordDetails() {
        activityIndicator.startAnimating()
        
        apiService.fetchWordDetails(word: word) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let responses):
                    if responses.isEmpty {
                        // Handle case where API returns empty array
                        self?.showNoWordFound()
                    } else {
                        self?.apiResponses = responses
                        self?.displayWordInfo()
                    }
                case .failure(let error as URLError) where error.code == .resourceUnavailable:
                    // Handle 404 - word not found
                    self?.showNoWordFound()
                case .failure(let error):
                    print("API Error: \(error.localizedDescription)")
                    self?.showNoWordFound()
                }
            }
        }
    }
    
    private func displayWordInfo() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        guard !apiResponses.isEmpty else {
            showNoWordFound()
            return
        }
        
        let wordLabel = UILabel()
        wordLabel.text = word.capitalized
        wordLabel.font = .systemFont(ofSize: 32, weight: .bold)
        wordLabel.textAlignment = .center
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wordLabel)
        
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            wordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        var previousView: UIView = wordLabel
        
        if let context = context {
            let contextLabel = UILabel()
            contextLabel.text = "\"\(context)\""
            contextLabel.font = .italicSystemFont(ofSize: 16)
            contextLabel.textColor = .secondaryLabel
            contextLabel.textAlignment = .center
            contextLabel.numberOfLines = 0
            contextLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(contextLabel)
            
            NSLayoutConstraint.activate([
                contextLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 8),
                contextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                contextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])
            
            previousView = contextLabel
        }
        
        for response in apiResponses {
            if let phonetic = response.phonetic {
                let phoneticLabel = UILabel()
                phoneticLabel.text = phonetic
                phoneticLabel.font = .systemFont(ofSize: 18)
                phoneticLabel.textColor = .secondaryLabel
                phoneticLabel.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(phoneticLabel)
                
                NSLayoutConstraint.activate([
                    phoneticLabel.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 16),
                    phoneticLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    phoneticLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ])
                
                previousView = phoneticLabel
            }
            
            for meaning in response.meanings {
                let posLabel = UILabel()
                posLabel.text = meaning.partOfSpeech.capitalized
                posLabel.font = .systemFont(ofSize: 20, weight: .semibold)
                posLabel.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(posLabel)
                
                NSLayoutConstraint.activate([
                    posLabel.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 24),
                    posLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    posLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ])
                
                previousView = posLabel
                
                let limitedDefinitions = Array(meaning.definitions.prefix(3))
                for (index, definition) in limitedDefinitions.enumerated() {
                    let definitionView = createDefinitionView(index: index + 1,
                                                           text: definition.definition,
                                                           example: definition.example)
                    contentView.addSubview(definitionView)
                    
                    NSLayoutConstraint.activate([
                        definitionView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 12),
                        definitionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                        definitionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                    ])
                    
                    previousView = definitionView
                }
            }
        }
        
        addDictionaryButton(below: previousView)
    }
    
    private func showNoWordFound() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add "Not found" message
        let notFoundLabel = UILabel()
        notFoundLabel.text = "No dictionary definition found for \"\(word)\""
        notFoundLabel.font = .systemFont(ofSize: 18)
        notFoundLabel.textAlignment = .center
        notFoundLabel.numberOfLines = 0
        notFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(notFoundLabel)
        
        NSLayoutConstraint.activate([
            notFoundLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -40),
            notFoundLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notFoundLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        addDictionaryButton(below: notFoundLabel)
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }
    
    private func addDictionaryButton(below view: UIView) {
        let dictionaryButton = UIButton(type: .system)
        dictionaryButton.setTitle("Open Web Dictionary", for: .normal)
        dictionaryButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        dictionaryButton.setTitleColor(.white, for: .normal)
        dictionaryButton.backgroundColor = .systemBlue
        dictionaryButton.layer.cornerRadius = 8
        dictionaryButton.translatesAutoresizingMaskIntoConstraints = false
        dictionaryButton.addTarget(self, action: #selector(openWebDictionary), for: .touchUpInside)
        contentView.addSubview(dictionaryButton)
        
        NSLayoutConstraint.activate([
            dictionaryButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 30),
            dictionaryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dictionaryButton.widthAnchor.constraint(equalToConstant: 200),
            dictionaryButton.heightAnchor.constraint(equalToConstant: 50),
            dictionaryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    @objc private func openWebDictionary() {
        let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? word
        let urlString = "https://dictionary.cambridge.org/dictionary/english/\(encodedWord)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func createDefinitionView(index: Int, text: String, example: String?) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let indexLabel = UILabel()
        indexLabel.text = "\(index)."
        indexLabel.font = .systemFont(ofSize: 14, weight: .medium)
        indexLabel.setContentHuggingPriority(.required, for: .horizontal)
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let definitionLabel = UILabel()
        definitionLabel.text = text
        definitionLabel.numberOfLines = 0
        definitionLabel.font = .systemFont(ofSize: 16)
        definitionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubviews(indexLabel, definitionLabel)
        
        NSLayoutConstraint.activate([
            indexLabel.topAnchor.constraint(equalTo: container.topAnchor),
            indexLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            definitionLabel.topAnchor.constraint(equalTo: container.topAnchor),
            definitionLabel.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 8),
            definitionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        if let example = example {
            let exampleLabel = UILabel()
            exampleLabel.text = "Example: \(example)"
            exampleLabel.numberOfLines = 0
            exampleLabel.font = .italicSystemFont(ofSize: 14)
            exampleLabel.textColor = .secondaryLabel
            exampleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(exampleLabel)
            
            NSLayoutConstraint.activate([
                exampleLabel.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: 6),
                exampleLabel.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 8),
                exampleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                exampleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else {
            definitionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        }

        return container
    }
    
    private func showError(error: Error) {
        let errorLabel = UILabel()
        errorLabel.text = "Error: \(error.localizedDescription)"
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func showLocalDefinition() {
        let localLabel = UILabel()
        localLabel.text = "No dictionary definition found.\nThis is a word you added to your personal dictionary."
        localLabel.textColor = .secondaryLabel
        localLabel.numberOfLines = 0
        localLabel.textAlignment = .center
        localLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(localLabel)
        
        NSLayoutConstraint.activate([
            localLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            localLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            localLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        if let context = context {
            let contextLabel = UILabel()
            contextLabel.text = "Your context: \"\(context)\""
            contextLabel.font = .italicSystemFont(ofSize: 16)
            contextLabel.textColor = .tertiaryLabel
            contextLabel.numberOfLines = 0
            contextLabel.textAlignment = .center
            contextLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(contextLabel)
            
            NSLayoutConstraint.activate([
                contextLabel.topAnchor.constraint(equalTo: localLabel.bottomAnchor, constant: 16),
                contextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                contextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                contextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        } else {
            localLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }
}
