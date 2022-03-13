//
//  ResultsViewController.swift
//  KobzaHelper
//
//  Created by User on 19.02.2022.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet var wordLabels: [UILabel]!
    @IBOutlet weak var indexLabel: UILabel!
    
    func setup(ind: Int, word: Word, greenIndexes: [Int]) {
        indexLabel.text = String(format: "%04d", ind)
        for (ind, val) in word.letters.enumerated() {
            let l = wordLabels[ind]
            l.text = String(val).uppercased()
            l.layer.masksToBounds = true
            l.layer.cornerRadius = 5
            
            if greenIndexes.contains(ind) {
                l.backgroundColor = #colorLiteral(red: 0.4186399281, green: 0.6722118855, blue: 0.4635387063, alpha: 1)
            } else {
                l.backgroundColor = .clear
            }
        }
    }
}

class ResultsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var words = [Word]() {
        didSet {
            title = "Found: \(words.count)"
        }
    }
    var greenIndexes = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
        cell.setup(ind: indexPath.row + 1, word: words[indexPath.row], greenIndexes: greenIndexes)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.bounds.width - (5 * 4) - 66) / 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
