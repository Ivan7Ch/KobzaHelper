//
//  ViewController2.swift
//  KobzaHelper
//
//  Created by User on 09.02.2022.
//

import UIKit

let attributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray4]

class ViewController2: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resultField: UITextView!
    @IBOutlet weak var excludeField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    var viewModel: ViewModel!
    var validationLetters = [Letter]()
    var excludeText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        viewModel = ViewModel(delegate: self)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        resultField.isEditable = false
        infoLabel.text = ""
        resultField.layer.cornerRadius = 5
        resultField.textColor = .white
        
        searchButton.layer.cornerRadius = 5
        searchButton.setTitle("", for: .normal)
        
        excludeField.attributedPlaceholder = NSAttributedString(string: "_", attributes: attributes)
        
        excludedTextSearch()
    }
    
    @IBAction func excludeLettersEditing(_ sender: UITextField) {
        excludeText = sender.text ?? ""
    }
    
    @IBAction func excludedTextSearch() {
        validationLetters.removeAll(where: { $0.type == .black })
        
        for i in Array(excludeText) {
            validationLetters.append(Letter(char: String(i), location: 0, type: .black))
        }
        
        viewModel = ViewModel(delegate: self, validationLetters: validationLetters)
        resultField.text = viewModel.arr.joined(separator: ", ")
        infoLabel.text = "Знайдено: \(viewModel.arr.count)"
    }
    
    @IBAction func clearButtonAction() {
        excludeText = ""
        validationLetters = []
        excludedTextSearch()
        excludeField.text = ""
        collectionView.reloadData()
    }
    
    @IBAction func expandArrowAction() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
        vc.words = viewModel.arr
        vc.greenIndexes = validationLetters.filter({ $0.type == .green }).map({ $0.location })
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension ViewController2: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GreenInputCollectionViewCell", for: indexPath) as! GreenInputCollectionViewCell
        let ind = indexPath.row
        
        cell.vc = self
        
        if ind < 5 {
            cell.backgroundColor = #colorLiteral(red: 0.4186399281, green: 0.6722118855, blue: 0.4635387063, alpha: 1)
            cell.type = .green
            cell.ind = ind
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.7764705882, green: 0.6431372549, blue: 0.2117647059, alpha: 1)
            cell.type = .yellow
            cell.ind = ind - 5
        }
        
        cell.layer.cornerRadius = 5
        
        return cell
    }
}


extension ViewController2: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
}


extension ViewController2: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 40) / 5
        
        return CGSize(width: width, height: 45)
    }
}

extension ViewController2: GameDelegate {
    
    func updateViews() {
        
        collectionView.reloadData()
    }
}


class GreenInputCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    var vc: ViewController2!
    var ind = 0
    var type: LetterType = .green
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.text = "_"
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
    }
}