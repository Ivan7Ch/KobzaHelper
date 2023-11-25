//
//  ViewController.swift
//  KobzaHelper
//
//  Created by User on 09.02.2022.
//

import UIKit

let attributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray4]

enum SortingType {
    
    case ranking
    case alphabetical
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resultField: UITextView!
    @IBOutlet weak var excludeField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var unlockButton: UIButton!
    
    var viewModel: ViewModel!
    var validationLetters = [Letter]()
    var excludeText = ""
    
    var sortingType: SortingType = .ranking {
        didSet {
            filterWords()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        collectionView.delegate = self
        collectionView.dataSource = self
        
        resultField.isEditable = false
        resultField.isSelectable = false
        infoLabel.text = ""
        resultField.layer.cornerRadius = 5
        resultField.textColor = .white
        resultField.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        excludeField.attributedPlaceholder = NSAttributedString(string: "_", attributes: attributes)
        
        activityIndicator.hidesWhenStopped = true
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tap)
        
        excludeField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        unlockButton.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterWords()
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }
    
    @IBAction func excludeLettersEditing(_ sender: UITextField) {
        excludeText = sender.text ?? ""
    }
    
    func filterWords() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
//        resultField.text = ""
        activityIndicator.startAnimating()
        
        validationLetters.removeAll(where: { $0.type == .black })
        
        for i in Array(excludeText) {
            validationLetters.append(Letter(char: String(i), location: 0, type: .black))
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let self = self {
                self.viewModel = ViewModel(delegate: self, validationLetters: self.validationLetters)
            }
            
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    let filteredArr = self.viewModel.arr.filter({ !$0.isLocked })
                    self.resultField.text = filteredArr.joinedString()
//                    self.infoLabel.text = "Доступно: \(filteredArr.count)\nЗнайдено всього: \(self.viewModel.arr.count)"
                    self.infoLabel.text = "Знайдено всього: \(self.viewModel.arr.count)"
                    self.activityIndicator.stopAnimating()
                }
                
            }
        }
    }
    
    @IBAction func clearButtonAction() {
        excludeText = ""
        validationLetters = []
        filterWords()
        excludeField.text = ""
        collectionView.reloadData()
    }
    
    @IBAction func expandArrowAction() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
        vc.words = viewModel.arr
        vc.greenIndexes = validationLetters.filter({ $0.type == .green }).map({ $0.location })
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        filterWords()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sortingType = .ranking
        default :
            sortingType = .alphabetical
        }
    }
    
    @IBAction func unlockButtonAction() {
        UserDefaults.standard.set(true, forKey: "isAllowed")
        
        unlockButton.isHidden = true
        filterWords()
    }
}


extension ViewController: UICollectionViewDataSource {
    
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


extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 40) / 5
        
        return CGSize(width: width, height: 45)
    }
}

extension ViewController: GameDelegate {
    
    func updateViews() {
        
        collectionView.reloadData()
    }
}
