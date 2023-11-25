//
//  InputCollectionViewCell.swift
//  KobzaHelper
//
//  Created by User on 27.03.2022.
//

import UIKit

class GreenInputCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    var vc: ViewController!
    var ind = 0
    var type: LetterType = .green
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(string: "_", attributes: attributes)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textField.attributedPlaceholder = NSAttributedString(string: "_", attributes: attributes)
        textField.text = ""
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        vc.validationLetters.removeAll(where: { $0.location == ind && $0.type == type })
        
        switch type {
        case .green:
            if let char = sender.text?.last {
                let str = String(char)
                sender.text = str.capitalized
                vc.validationLetters.append(Letter(char: str, location: ind, type: type))
            }
            
        case .yellow:
            if let str = sender.text, !str.isEmpty {
                let filteredStr = str.trimmingCharacters(in: .letters.inverted).lowercased()
                sender.text = filteredStr.uppercased()
                
                for i in Array(filteredStr) {
                    vc.validationLetters.append(Letter(char: String(i), location: ind, type: type))
                }
            }
            
        case .black:
            return
        }
        
        vc.filterWords()
    }
}
