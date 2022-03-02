//
//  ViewController.swift
//  KobzaHelper
//
//  Created by User on 08.02.2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var allWordsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ViewModel(delegate: self)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        updateViews()
    }
    
    @IBAction func didTapOnReload() {
        
        viewModel.reloadGame()
    }
    
    @IBAction func didTapOnNewRow() {
        
        viewModel.getNewWord()
        updateViews()
    }
}


extension ViewController: GameDelegate {
    
    func updateViews() {
        
        infoLabel.text = "Доступні варіанти слів(\(viewModel.getPossibleVariantsAmount())):"
        
        allWordsLabel.text = viewModel.allWordsText()
        collectionView.reloadData()
    }
}


extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LetterCollectionViewCell", for: indexPath) as! LetterCollectionViewCell
        
        let letter = viewModel.getLetter(for: indexPath.row)
        cell.letterLabel.text = letter.char.capitalized
        
        switch letter.type {
        case .green:
            cell.backgroundColor = .systemGreen
        case .yellow:
            cell.backgroundColor = .systemOrange
        case .black:
            cell.backgroundColor = .black
        }
        
        cell.layer.cornerRadius = 5
        
        return cell
    }
}


extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.didTap(at: indexPath.row)
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 40) / 5
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
}


class LetterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var letterLabel: UILabel!
    
}
