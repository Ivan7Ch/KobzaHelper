//
//  WordListViewController.swift
//  KobzaHelper
//
//  Created by Ivan Chernetskiy on 25.11.2023.
//

import UIKit

class WordListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var words: [Word] = []
    var filteredWords: [Word] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        loadWords()
        
        searchBar.barTintColor = UIColor(red: 64/255, green: 46/255, blue: 76/255, alpha: 1)
        searchBar.tintColor = UIColor.white
        searchBar.searchTextField.backgroundColor = UIColor(red: 54/255, green: 36/255, blue: 66/255, alpha: 1)

    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Додати слово", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Введіть слово"
        }
        
        let addAction = UIAlertAction(title: "Додати", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let newWordText = textField.text, newWordText.count == 5 {
                let newWordLetters = newWordText.map { String($0) } // Конвертуємо рядок у масив букв
                let newWord = Word(letters: newWordLetters, rating: 0)
                
                // Додамо нове слово до масиву і сортуємо його за алфавітом
                self?.filteredWords.append(newWord)
                self?.filteredWords.sort { $0.letters.joined() < $1.letters.joined() }
                
                self?.words.append(newWord)
                self?.words.sort { $0.letters.joined() < $1.letters.joined() }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                UserDefaultsHelper.shared.saveWords(self?.words ?? [])
            } else {
                // Вивести повідомлення про помилку, якщо слово не має 5 букв
                let errorAlertController = UIAlertController(title: "Помилка", message: "Слово повинно містити рівно 5 букв", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                errorAlertController.addAction(okAction)
                self?.present(errorAlertController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Скасувати", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    func loadWords() {
        words = UserDefaultsHelper.shared.getWords().sorted { $0.letters.joined() < $1.letters.joined() }
        filteredWords = words
        tableView.reloadData()
    }
    
    // MARK: - UISearchBarDelegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredWords = searchText.isEmpty ? words : words.filter { $0.string.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordListTableViewCell", for: indexPath) as! WordListTableViewCell
        
        let word = filteredWords[indexPath.row]
        cell.configure(with: word, at: indexPath.row)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedWord = filteredWords.remove(at: indexPath.row)
            if let indexInWords = words.firstIndex(where: { $0.letters == deletedWord.letters }) {
                words.remove(at: indexInWords)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            UserDefaultsHelper.shared.saveWords(words)
        }
    }
}
