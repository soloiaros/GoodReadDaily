import UIKit
import SwiftData

protocol AddWordDelegate: AnyObject {
    func didAddWord(_ word: SDDictionaryEntry)
}

class AddWordViewController: UIViewController {
    
    weak var delegate: AddWordDelegate?
    
    private let wordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Word"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let contextTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }()
    
    private let contextPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Context (optional)"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Add New Word"
        
        setupNavigationBar()
        setupViews()
        setupTextFields()
    }
    
    // New: Method to pre-fill word text field
    func setInitialWord(_ word: String) {
        wordTextField.text = word
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [
            createLabel("Word"),
            wordTextField,
            createLabel("Context (optional)"),
            contextTextView
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contextTextView.addSubview(contextPlaceholderLabel)
        contextPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contextTextView.heightAnchor.constraint(equalToConstant: 120),
            
            contextPlaceholderLabel.topAnchor.constraint(equalTo: contextTextView.topAnchor, constant: 8),
            contextPlaceholderLabel.leadingAnchor.constraint(equalTo: contextTextView.leadingAnchor, constant: 8)
        ])
    }
    
    private func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    private func setupTextFields() {
        wordTextField.delegate = self
        contextTextView.delegate = self
        wordTextField.becomeFirstResponder()
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let word = wordTextField.text?.trimmingCharacters(in: .whitespaces), !word.isEmpty else {
            showAlert(title: "Missing Word", message: "Please enter a word")
            return
        }
        
        let context = contextTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let newEntry = SDDictionaryEntry(word: word, context: context.isEmpty ? nil : context)
        
        if let userData = SwiftDataManager.shared.getUserData() {
            if !userData.savedWords.contains(where: { $0.word.lowercased() == word.lowercased() }) {
                userData.savedWords.append(newEntry)
                SwiftDataManager.shared.save()
                delegate?.didAddWord(newEntry)
                dismiss(animated: true)
            } else {
                showAlert(title: "Duplicate Word", message: "This word is already in your dictionary")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddWordViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contextTextView.becomeFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        contextPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
}
