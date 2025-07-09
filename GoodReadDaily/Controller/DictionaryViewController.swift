//
//  DictionaryViewController.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/6/25.
//

import UIKit

class DictionaryViewController: UIViewController {
    private var tableView: UITableView!
    private var savedWords: [DictionaryEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Dictionary"
        
        setupTableView()
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
        if let userData = UserDefaults.standard.data(forKey: "userData") {
            let decoder = JSONDecoder()
            if let decoder = try? decoder.decode(UserData.self, from: userData) {
                savedWords = decoder.savedWords.sorted {
                    $0.dateAdded > $1.dateAdded }
                tableView.reloadData()
                showEmptyState()
            }
        }
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
        
        // Configure cell with word and context if available
        if let context = wordEntry.context {
            cell.textLabel?.text = "\(wordEntry.word) - \(context)"
        } else {
            cell.textLabel?.text = wordEntry.word
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator // For future clickability
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // for future, to make clickable
        let wordEntry = savedWords[indexPath.row]
        print("Selected word: \(wordEntry.word)")
    }
}



// for word adding implementation:
/*
 // When adding a word to dictionary
 let newEntry = DictionaryEntry(word: selectedWord, context: surroundingText)
 UserDefaultsHelper.addDictionaryEntry(newEntry)
 */
