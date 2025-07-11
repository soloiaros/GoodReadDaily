

import UIKit
import FirebaseAuth
import SwiftData

final class ArticleViewController: UIViewController {
    private let article: Article
    private var currentFontSize: CGFloat = 18 {
        didSet {
            updateFontSizes()
            fontSizeControlView?.updateSize(currentFontSize)
        }
    }
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let authorLabel = UILabel()
    private let genreLabel = UILabel()
    private let idLabel = UILabel()
    private let contentTextView = UITextView()
    private let readButton = UIButton(type: .system)
    private var fontSizeControlView: FontSizeControlView?
    
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
        contentTextView.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 220/255, alpha: 1.0)
        setupUI()
        configure(with: article)
        updateReadButtonState()
        setupGestures()
        setupContextMenu() // New: Setup context menu
        markArticleAsInProgress()
    }
    
    private func setupGestures() {
        let tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tripleTapGesture.numberOfTapsRequired = 3
        contentTextView.addGestureRecognizer(tripleTapGesture)
        contentTextView.isUserInteractionEnabled = true
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if fontSizeControlView == nil {
            showFontSizeControls()
        } else {
            hideFontSizeControls()
        }
    }
    
    private func showFontSizeControls() {
        fontSizeControlView = FontSizeControlView(currentSize: currentFontSize)
        guard let fontSizeControlView = fontSizeControlView else { return }
        
        fontSizeControlView.onIncrease = { [weak self] in
            self?.currentFontSize += 1
        }
        
        fontSizeControlView.onDecrease = { [weak self] in
            self?.currentFontSize -= 1
        }
        
        fontSizeControlView.onClose = { [weak self] in
            self?.hideFontSizeControls()
        }
        
        view.addSubview(fontSizeControlView)
        fontSizeControlView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fontSizeControlView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fontSizeControlView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            fontSizeControlView.widthAnchor.constraint(equalToConstant: 200),
            fontSizeControlView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        fontSizeControlView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
            fontSizeControlView.transform = .identity
        })
    }
    
    private func hideFontSizeControls() {
        UIView.animate(withDuration: 0.2, animations: {
            self.fontSizeControlView?.alpha = 0
            self.fontSizeControlView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            self.fontSizeControlView?.removeFromSuperview()
            self.fontSizeControlView = nil
        }
    }
    
    private func updateFontSizes() {
        contentTextView.font = UIFont.systemFont(ofSize: currentFontSize)
        titleLabel.font = UIFont.boldSystemFont(ofSize: currentFontSize + 6)
        subtitleLabel.font = UIFont.italicSystemFont(ofSize: currentFontSize - 2)
        authorLabel.font = UIFont.systemFont(ofSize: currentFontSize - 4)
        genreLabel.font = UIFont.systemFont(ofSize: currentFontSize - 4)
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
        authorLabel.textAlignment = .right
        contentView.addSubview(authorLabel)
               
        // Genre Label
        genreLabel.font = UIFont.systemFont(ofSize: 14)
        genreLabel.textColor = .darkGray
        genreLabel.textAlignment = .right
        contentView.addSubview(genreLabel)
        
        
        // ID Label
        idLabel.font = UIFont.systemFont(ofSize: 0)
        idLabel.textColor = .lightGray
        contentView.addSubview(idLabel)
        
        // Content TextView
        contentTextView.font = UIFont(name: "Tinos-Regular", size: 21)
        contentTextView.isEditable = false
        contentTextView.isSelectable = true
        contentTextView.isScrollEnabled = false
        contentTextView.textContainerInset = .zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.dataDetectorTypes = .all
        contentView.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 220/255, alpha: 1.0)
        contentView.tintColor =  UIColor(red: 255/255, green: 245/255, blue: 220/255, alpha: 1.0)
        contentView.addSubview(contentTextView)
        
        // Read Button Settings
        readButton.setTitle("Mark as Read", for: .normal)
        readButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        readButton.backgroundColor = UIColor(red: 191/255, green: 155/255, blue: 132/255, alpha: 0.51)
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
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        readButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                 
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                 
            authorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
             
                 
            genreLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                 
            idLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 0),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                 
            contentTextView.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                 
            readButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 24),
            readButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            readButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            readButton.heightAnchor.constraint(equalToConstant: 44),
            readButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
             ])
    }
    
    private func setupContextMenu() {
        let addToDictionary = UIMenuItem(title: "Add to Dictionary", action: #selector(addToDictionaryTapped))
        UIMenuController.shared.menuItems = [addToDictionary]
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(addToDictionaryTapped) {
            if let selectedRange = contentTextView.selectedTextRange, !selectedRange.isEmpty {
                return true
            }
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    @objc private func addToDictionaryTapped() {
        guard let selectedRange = contentTextView.selectedTextRange,
              let selectedText = contentTextView.text(in: selectedRange)?.trimmingCharacters(in: .whitespaces) else {
            return
        }
        
        let addWordVC = AddWordViewController()
        addWordVC.delegate = self
        addWordVC.setInitialWord(selectedText)
        
        let navController = UINavigationController(rootViewController: addWordVC)
        present(navController, animated: true)
    }
    
    private func configure(with article: Article) {
        title = article.title
        titleLabel.text = article.title
        subtitleLabel.text = article.subtitle
        authorLabel.text = "By \(article.author)"
        genreLabel.text = "#\(article.genre)"
        idLabel.text = "ID: \(article.id)"
        contentTextView.text = article.content
    }
    
    private func updateReadButtonState() {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            readButton.setTitle("Mark as Read", for: .normal)
            readButton.backgroundColor = UIColor(red: 191/255, green: 155/255, blue: 132/255, alpha: 0.51)
            return
        }
        let isRead = userData.completedArticleIDs.contains(article.id)
        
        if isRead {
            readButton.setTitle("✓ Read", for: .normal)
            readButton.backgroundColor = UIColor(red: 89/255, green: 101/255, blue: 123/255, alpha: 1.0)
        } else {
            readButton.setTitle("Mark as Read", for: .normal)
            readButton.backgroundColor = UIColor(red: 191/255, green: 155/255, blue: 132/255, alpha: 0.51)
        }
    }
    
    private func markArticleAsInProgress() {
        guard let userData = SwiftDataManager.shared.getUserData(),
              !userData.inProgressArticleIDs.contains(article.id) else {
            return
        }
        userData.inProgressArticleIDs.append(article.id)
        SwiftDataManager.shared.save()
    }
    
    @objc private func readButtonTapped() {
        guard let userData = SwiftDataManager.shared.getUserData() else {
            return
        }
        let articleID = article.id
        
        if userData.completedArticleIDs.contains(articleID) {
            showDeleteConfirmationAlert { [weak self] shouldDelete in
                guard let self = self else { return }
                
                if shouldDelete {
                    if let index = userData.completedArticleIDs.firstIndex(of: articleID) {
                        userData.completedArticleIDs.remove(at: index)
                        SwiftDataManager.shared.save()
                        animateButtonChange()
                    }
                }
            }
        } else {
            userData.completedArticleIDs.append(articleID)
            if let index = userData.inProgressArticleIDs.firstIndex(of: articleID) {
                userData.inProgressArticleIDs.remove(at: index)
            }
            SwiftDataManager.shared.save()
            animateButtonChange()
        }
    }
    
    private func showDeleteConfirmationAlert(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "Remove from read articles?",
            message: "Are you sure you want to remove this article from your read list?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion(true)
        })
        
        present(alert, animated: true)
    }
    
    private func animateButtonChange() {
        UIView.animate(withDuration: 0.3, animations: {
            self.readButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.readButton.transform = .identity
                self.updateReadButtonState()
            }
        }
    }
}

// New: Adopt AddWordDelegate protocol
extension ArticleViewController: AddWordDelegate {
    func didAddWord(_ word: SDDictionaryEntry) {
        let alert = UIAlertController(
            title: "Word Added",
            message: "\(word.word) has been added to your dictionary.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class FontSizeControlView: UIView {
    var onIncrease: (() -> Void)?
    var onDecrease: (() -> Void)?
    var onClose: (() -> Void)?
    
    private let sizeLabel = UILabel()
    private let decreaseButton = UIButton(type: .system)
    private let increaseButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    
    init(currentSize: CGFloat) {
        super.init(frame: .zero)
        setupView(currentSize: currentSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(currentSize: CGFloat) {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        decreaseButton.setTitle("-", for: .normal)
        decreaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        
        increaseButton.setTitle("+", for: .normal)
        increaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        
        sizeLabel.text = "\(Int(currentSize))"
        sizeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        sizeLabel.textAlignment = .center
        
        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [decreaseButton, sizeLabel, increaseButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        addSubview(stackView)
        addSubview(closeButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func updateSize(_ size: CGFloat) {
        sizeLabel.text = "\(Int(size))"
    }
    
    @objc private func decreaseTapped() {
        onDecrease?()
    }
    
    @objc private func increaseTapped() {
        onIncrease?()
    }
    
    @objc private func closeTapped() {
        onClose?()
    }
}

