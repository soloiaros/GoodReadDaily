
import UIKit
import SwiftData

class DictionaryViewController: UIViewController {
    private var tableView: UITableView!
    private var savedWords: [SDDictionaryEntry] = []
    private var floatingButton: FloatingActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Dictionary"
        
        setupTableView()
        setupFloatingButton()
        loadSavedWords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedWords()
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WordCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadSavedWords() {
        if let userData = SwiftDataManager.shared.getUserData() {
            savedWords = userData.savedWords.sorted { $0.dateAdded > $1.dateAdded }
            tableView.reloadData()
            showEmptyState()
        }
    }
    
    private func setupFloatingButton() {
        floatingButton = FloatingActionButton()
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            floatingButton.widthAnchor.constraint(equalToConstant: 56),
            floatingButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func floatingButtonTapped() {
        let addWordVC = AddWordViewController()
        addWordVC.delegate = self
        let navController = UINavigationController(rootViewController: addWordVC)
        present(navController, animated: true)
    }
    
    private func showEmptyState() {
        if savedWords.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Your dictionary is empty.\nAdd words to see them here."
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            emptyLabel.textColor = .gray
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension DictionaryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        let wordEntry = savedWords[indexPath.row]
        
        if let context = wordEntry.context {
            cell.textLabel?.text = "\(wordEntry.word) - \(context)"
        } else {
            cell.textLabel?.text = wordEntry.word
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let wordEntry = savedWords[indexPath.row]
        let detailVC = WordDetailViewController(word: wordEntry.word, context: wordEntry.context)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableview: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            self?.showDeleteConfirmation(for: indexPath, completion: completion)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    private func showDeleteConfirmation(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "Delete Word",
            message: "Are you sure you want to delete this word?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteWord(at: indexPath)
            completion(true)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteWord(at indexPath: IndexPath) {
        guard indexPath.row < savedWords.count else { return }
        
        let deletedWord = savedWords[indexPath.row]
        savedWords.remove(at: indexPath.row)
        
        if let userData = SwiftDataManager.shared.getUserData() {
            userData.savedWords = savedWords
            SwiftDataManager.shared.save()
        }
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .left)
        }, completion: { _ in
            self.showEmptyState()
            self.showUndoOption(for: deletedWord, originalIndexPath: indexPath)
        })
    }
    
    private func showUndoOption(for word: SDDictionaryEntry, originalIndexPath: IndexPath) {
        let undoView = UIView()
        undoView.backgroundColor = .systemGray5
        undoView.layer.cornerRadius = 8
        undoView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Word deleted"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let undoButton = UIButton(type: .system)
        undoButton.setTitle("Undo", for: .normal)
        undoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.addTarget(self, action: #selector(undoDelete), for: .touchUpInside)
        
        undoView.addSubview(label)
        undoView.addSubview(undoButton)
        
        view.addSubview(undoView)
        
        NSLayoutConstraint.activate([
            undoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            undoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            undoView.heightAnchor.constraint(equalToConstant: 50),
            undoView.widthAnchor.constraint(equalToConstant: 200),
            
            label.leadingAnchor.constraint(equalTo: undoView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: undoView.centerYAnchor),
            
            undoButton.trailingAnchor.constraint(equalTo: undoView.trailingAnchor, constant: -16),
            undoButton.centerYAnchor.constraint(equalTo: undoView.centerYAnchor)
        ])
        
        undoView.tag = originalIndexPath.row
        objc_setAssociatedObject(undoView, &AssociatedKeys.deletedWord, word, .OBJC_ASSOCIATION_RETAIN)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3, animations: {
                undoView.alpha = 0
            }, completion: { _ in
                undoView.removeFromSuperview()
            })
        }
    }

    @objc private func undoDelete(_ sender: UIButton) {
        guard let undoView = sender.superview,
              let word = objc_getAssociatedObject(undoView, &AssociatedKeys.deletedWord) as? SDDictionaryEntry else {
            return
        }
        
        let originalPosition = undoView.tag
        savedWords.insert(word, at: originalPosition)
        
        if let userData = SwiftDataManager.shared.getUserData() {
            userData.savedWords = savedWords
            SwiftDataManager.shared.save()
        }
        
        tableView.insertRows(at: [IndexPath(row: originalPosition, section: 0)], with: .automatic)
        undoView.removeFromSuperview()
        showEmptyState()
    }

    private struct AssociatedKeys {
        static var deletedWord = "deletedWord"
    }
}

extension DictionaryViewController: AddWordDelegate {
    func didAddWord(_ word: SDDictionaryEntry) {
        savedWords.insert(word, at: 0)
        if let userData = SwiftDataManager.shared.getUserData() {
            userData.savedWords = savedWords
            SwiftDataManager.shared.save()
        }
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.endUpdates()
        
        showEmptyState()
    }
}
