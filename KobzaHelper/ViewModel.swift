//
//  ViewModel.swift
//  KobzaHelper
//
//  Created by User on 08.02.2022.
//

import Foundation

protocol GameDelegate {
    
    func updateViews()
}

enum LetterType {
    
    case green
    case yellow
    case black
}

struct Letter {
    
    let char: String
    let location: Int
    let type: LetterType
    
    static var standart: Letter {
        return Letter(char: "_", location: 0, type: .black)
    }
}

class ViewModel {
    
    let delegate: GameDelegate
    
    var arr = [String]()
    
    var selectedLetters = [Letter]()
    var topWord = [Letter]()
    
    private var lettersDictionary = [String : Int]()
    private var initialArray = [String]()
    
    init(delegate: GameDelegate, validationLetters: [Letter] = []) {
        
        self.delegate = delegate
        
        setupFrequentArr()
        
        let arrWithDublicates = DataSource.words.components(separatedBy: .newlines).map({ String($0) })
        let set = Set(arrWithDublicates)
    
        initialArray = Array(set)
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
        let arrayOfChars = Array(item).map({ String($0) })
        for (index, value) in arrayOfChars.enumerated() {
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
        
        return arr.joined(separator: ", ")
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
        
        arr = arr.sorted(by: { getVolumeOfWord(str: $0) > getVolumeOfWord(str: $1) })
    }
    
    private func getVolumeOfWord(str: String) -> Int {
        var res = 0
        
        let set = Set(Array(str))
        for i in set {
            res += lettersDictionary[String(i)] ?? 0
        }
        
        return res
    }
    
    private func setupFrequentArr() {
        
        var str = DataSource.words.replacingOccurrences(of: " ", with: "")
        str = str.replacingOccurrences(of: "\'", with: "")
        str = str.lowercased()
        
        let arr = Array(str)
        for item in arr {
            let i = String(item)
            if lettersDictionary[i] == nil {
                lettersDictionary[i] = 1
            } else {
                lettersDictionary[i]! += 1
            }
        }
    }
    
    private func filterIncludedGreen(letter: Letter, _ array: [String]) -> [String] {
        
        var result = [String]()
        
        for i in array {
            let wordArray = Array(String(i))
            if wordArray[letter.location] == Character(letter.char) {
                result.append(i)
            }
        }
        
        return result
    }
    
    private func filterIncludedYellow(letter: Letter, _ array: [String]) -> [String] {
        
        var result = [String]()
        
        for i in array {
            let wordArray = Array(String(i))
            if i.contains(letter.char), wordArray[letter.location] != Character(letter.char) {
                result.append(i)
            }
        }
        
        return result
    }

    private func filterExcluded(letter: Letter, _ array: [String]) -> [String] {
        var result = [String]()
        
        for i in array {
            let wordArray = Array(String(i))
            if !wordArray.contains(Character(letter.char)) {
                result.append(i)
            }
        }
        
        return result
    }
}
