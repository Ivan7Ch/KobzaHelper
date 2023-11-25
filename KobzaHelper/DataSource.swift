//
//  DataSource.swift
//  KobzaHelper
//
//  Created by User on 08.02.2022.
//

import Foundation

class DataSource {
    static let shared = DataSource()
    
    private(set) var words: [Word] = []
    
    private init() {
        loadWords()
    }
    
    private func loadWords() {
        if let filepath = Bundle.main.path(forResource: "WordsJson", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                words = try JSONDecoder().decode([Word].self, from: contents.data(using: .utf8)!)
            } catch {
                print(error)
            }
        }
    }
}
