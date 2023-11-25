//
//  WordListTableViewCell.swift
//  KobzaHelper
//
//  Created by Ivan Chernetskiy on 25.11.2023.
//

import UIKit

import UIKit

class WordListTableViewCell: UITableViewCell {
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    
    func configure(with word: Word, at index: Int) {
        // Форматуємо індекс у вигляді "0001", "0002" і так далі
        let formattedIndex = String(format: "%04d", index + 1)
        indexLabel.text = formattedIndex
        wordLabel.text = word.string
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Ініціалізація коду для ячейки, якщо потрібно
    }
}
