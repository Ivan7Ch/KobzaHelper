//
//  Word.swift
//  KobzaHelper
//
//  Created by User on 13.03.2022.
//

import Foundation

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

struct Word: Codable {

    let letters: [String]
    let rating: Int
    
    var string: String {
        return letters.joined()
    }
}

extension Array where Element == Word {
    
    func joinedString() -> String {
        return self.map({ $0.string }).joined(separator: ", ")
    }
    
    func primarySorted() -> [Word] {
        return self.sorted(by: { $0.rating > $1.rating })
    }
}