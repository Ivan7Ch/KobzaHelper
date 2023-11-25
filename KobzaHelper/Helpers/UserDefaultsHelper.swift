//
//  UserDefaultsHelper.swift
//  KobzaHelper
//
//  Created by Ivan Chernetskiy on 25.11.2023.
//

import Foundation

class UserDefaultsHelper {
    static let shared = UserDefaultsHelper()
    
    private var words: [Word] = []
    
    private init() {
        loadWords()
    }
    
    func getWords() -> [Word] {
        return words
    }
    
    func addWord(_ word: String, withRating rating: Int) {
        let newWord = Word(letters: [word], rating: rating)
        addWordIfNotExists(newWord)
    }
    
    func removeWord(at index: Int) {
        guard index >= 0, index < words.count else {
            return
        }
        
        words.remove(at: index)
        saveWords()
    }
    
    func saveWords(_ wordsToSave: [Word]) {
        words = wordsToSave
        saveWords()
    }
    
    func addWordIfNotExists(_ word: Word) {
        // Перевіряємо, чи таке слово вже є у базі даних
        if !words.contains(where: { $0.letters == word.letters }) {
            words.append(word)
            saveWords()
        }
    }
    
    func saveWordsIfNotExist(_ newWords: [Word]) {
        // Перевіряємо, чи такі слова вже є у базі даних
        let existingWords = Set(words)
        let uniqueNewWords = newWords.filter { !existingWords.contains($0) }
        
        // Додаємо унікальні слова до масиву
        words.append(contentsOf: uniqueNewWords)
        
        // Зберігаємо оновлений масив слів
        saveWords()
    }
    
    private func loadWords() {
        let userDefaults = UserDefaults.standard
        
        if let savedData = userDefaults.data(forKey: "words"),
           let decodedWords = try? JSONDecoder().decode([Word].self, from: savedData) {
            words = decodedWords
        }
    }
    
    private func saveWords() {
        let userDefaults = UserDefaults.standard
        
        if let encodedData = try? JSONEncoder().encode(words) {
            userDefaults.set(encodedData, forKey: "words")
        }
    }
}
