//
//  ViewModel.swift
//  KobzaHelper
//
//  Created by User on 08.02.2022.
//

import Foundation

protocol GameDelegate {
    
    var sortingType: SortingType { get }
    func updateViews()
}

class ViewModel {
    
    let delegate: GameDelegate
    
    var arr = [Word]()
    
    var selectedLetters = [Letter]()
    var topWord = [Letter]()
    
    private var initialArray = [Word]()
    
    init(delegate: GameDelegate, validationLetters: [Letter] = []) {
        
        self.delegate = delegate
        
        initialArray = DataSource.words
        arr = initialArray
        
        selectedLetters = validationLetters
        getNewWord()
    }
    
    func getNewWord() {
        
        validateArr()
        sortArr()
        
        guard var item = arr.first else { return }
        
        let percent = Int(arr.count / 100)
        if percent > 0, let element = arr[0..<percent].randomElement() {
            item = element
        }
        
        
        var word = [Letter]()
        for (index, value) in item.letters.enumerated() {
            let newLetter = Letter(char: value, location: index, type: .black)
            word.append(newLetter)
        }
        
        topWord = word
        
        for i in word {
            if !selectedLetters.contains(where: { $0.char == i.char }) {
                selectedLetters.append(i)
            }
        }
    }
    
    func getLetter(for index: Int) -> Letter {
        let l = topWord[index]
        if let type = selectedLetters.first(where: { $0.char == l.char })?.type {
            return Letter(char: l.char, location: index, type: type)
        }
        return l
    }
    
    func getPossibleVariantsAmount() -> Int {
        
        return arr.count
    }
    
    func allWordsText() -> String {
        
        return arr.joinedString()
    }
    
    func didTap(at index: Int) {
        
        let selectedLetter = getLetter(for: index)
        var newType: LetterType = .black
        
        switch selectedLetter.type {
        case .green:
            newType = .black
        case .yellow:
            newType = .green
        case .black:
            newType = .yellow
        }
        
        let newLetter = Letter(char: selectedLetter.char, location: index, type: newType)
        if let indexOfItem = selectedLetters.firstIndex(where: { $0.char == newLetter.char }) {
            selectedLetters[indexOfItem] = newLetter
            topWord[index] = newLetter
        }
        
        delegate.updateViews()
    }
    
    func reloadGame() {
        
        arr = initialArray
        selectedLetters = []
        getNewWord()
        delegate.updateViews()
    }
    
    private func validateArr() {
        
        arr = initialArray
        for i in selectedLetters {
            switch i.type {
            case .green:
                arr = filterIncludedGreen(letter: i, arr)
            case .yellow:
                arr = filterIncludedYellow(letter: i, arr)
            case .black:
                if selectedLetters.contains(where: { $0.char == i.char && $0.type != .black }) {
                    continue
                }
                arr = filterExcluded(letter: i, arr)
            }
        }
    }
    
    private func sortArr() {
        
        arr = arr.sorted(by: delegate.sortingType)
    }
    
    private func filterIncludedGreen(letter: Letter, _ array: [Word]) -> [Word] {
        
        var result = [Word]()
        
        for i in array {
            if i.letters[letter.location] == letter.char {
                result.append(i)
            }
        }
        
        return result
    }
    
    private func filterIncludedYellow(letter: Letter, _ array: [Word]) -> [Word] {
        
        var result = [Word]()
        
        for i in array {
            if i.letters.contains(letter.char), i.letters[letter.location] != letter.char {
                result.append(i)
            }
        }
        
        return result
    }

    private func filterExcluded(letter: Letter, _ array: [Word]) -> [Word] {
        var result = [Word]()
        
        for i in array {
            if !i.letters.contains(letter.char) {
                result.append(i)
            }
        }
        
        return result
    }
}
