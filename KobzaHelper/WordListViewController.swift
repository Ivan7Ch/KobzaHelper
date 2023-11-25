//
//  WordListViewController.swift
//  KobzaHelper
//
//  Created by Ivan Chernetskiy on 25.11.2023.
//

import UIKit

class WordListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var words: [Word] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        loadWords()
    }
    
    func loadWords() {
        words = UserDefaultsHelper.shared.getWords().sorted { $0.string < $1.string }
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Додати слово", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Введіть слово"
        }
        
        let addAction = UIAlertAction(title: "Додати", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let newWordText = textField.text, !newWordText.isEmpty {
                let newWordLetters = newWordText.map { String($0) }
                let newWord = Word(letters: newWordLetters, rating: 0)

                self?.words.append(newWord)
                self?.words.sort { $0.letters.joined() < $1.letters.joined() }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
                UserDefaultsHelper.shared.saveWords(self?.words ?? [])
            }
        }
        
        let cancelAction = UIAlertAction(title: "Скасувати", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    // MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordListTableViewCell", for: indexPath) as! WordListTableViewCell
        
        let word = words[indexPath.row]
        cell.configure(with: word, at: indexPath.row)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            words.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            UserDefaultsHelper.shared.saveWords(words)
        }
    }
}

