//
//  WordleHelper.swift
//  WordleHelperSwift
//
//  Created by Sean Antony on 13/01/2022.
//

import Foundation
import Rainbow

@main
final class WordleHelper {
    
    private let wordSize = 5
    private let allLetters: Set<Character> = Set([
    "q","w","e","r","t","y","u","i","o","p",
      "a","s","d","f","g","h","j","k","l",
          "z","x","c","v","b","n","m"
    ])
    private let ordinalFormatter = NumberFormatter()
    private let maxSearchCount = 10
    private var searchCount = 0
    
    init() {
        ordinalFormatter.numberStyle = .ordinal
    }
    
    static func main() async throws {
        try await WordleHelper().run()
    }
    
    func run(prevGreenChar1: Character? = nil,
             prevGreenChar2: Character? = nil,
             prevGreenChar3: Character? = nil,
             prevGreenChar4: Character? = nil,
             prevGreenChar5: Character? = nil,
             prevExcludedChars: [Character] = []) async throws
    {
        print(" Wordle Search #\(searchCount + 1) ".white.onLightBlue.bold)
        //Read input
        let g1 = getGreenCharInput(position: 1, prevGreenChar: prevGreenChar1)
        let g2 = getGreenCharInput(position: 2, prevGreenChar: prevGreenChar2)
        let g3 = getGreenCharInput(position: 3, prevGreenChar: prevGreenChar3)
        let g4 = getGreenCharInput(position: 4, prevGreenChar: prevGreenChar4)
        let g5 = getGreenCharInput(position: 5, prevGreenChar: prevGreenChar5)
        let enterGreyCharsText = " Enter grey characters\(prevExcludedChars.isEmpty ? ": " : " [\(String(prevExcludedChars))]: ")"
        print(enterGreyCharsText.lightBlack, terminator: "")
        guard let greyChars = readLine()?.lowercased() else { exit(0) }
        let greenChars = [g1, g2, g3, g4, g5]
        let greyCharsExcludingGreen = Set(Array(greyChars)).subtracting(Set(greenChars.compactMap { $0 }))
        let excludedChars = greyChars.isEmpty ? prevExcludedChars : Array(greyCharsExcludingGreen)
        
        //Perform search
        try await search(greenChars: greenChars, excludedChars: excludedChars)
        
        //Repeat
        searchCount += 1
        guard searchCount < maxSearchCount else {
            print(" \(maxSearchCount) searches allowed per program run. ".red.onWhite)
            exit(0)
        }
        print(" Search again? [Y/n]: ".lightYellow, terminator: "")
        let searchAgain = readLine()
        if searchAgain == "y" || searchAgain == "Y" || searchAgain == "" {
            print("")
            try await run(prevGreenChar1: g1,
                          prevGreenChar2: g2,
                          prevGreenChar3: g3,
                          prevGreenChar4: g4,
                          prevGreenChar5: g5,
                          prevExcludedChars: excludedChars)
        } else {
            exit(0)
        }
    }

    private func getGreenCharInput(position: Int, prevGreenChar: Character? = nil) -> Character? {
        let text = " Enter \(ordinalFormatter.string(from: NSNumber(value: position))!) green character\(prevGreenChar == nil ? ": " : " [\(String(prevGreenChar!))]: ")"
        print(text.lightGreen, terminator: "")
        guard let r = readLine()?.lowercased() else { exit(0) }
        return r.isEmpty ? prevGreenChar : r.first
    }

    private func search(greenChars: [Character?], excludedChars: [Character]) async throws {
        print(" Searching dictionary...".lightCyan)
        let (bytes, _) = try await URLSession.shared.bytes(from: URL(string: "file:///usr/share/dict/words")!)
        let regex = try NSRegularExpression(pattern: "[\(String(Set(allLetters).subtracting(excludedChars)))]{\(wordSize)}", options: [.caseInsensitive])
        var count = 0
        outerLoop: for try await word in bytes.lines {
            guard word.count == wordSize else { continue }
            for (index, char) in greenChars.enumerated() {
                if let char = char, char.isLetter, (word[word.index(word.startIndex, offsetBy: index)] != char) {
                    continue outerLoop
                }
            }
            guard (regex.firstMatch(in: word, range: NSRange(location: 0, length: word.count)) != nil) else { continue }
            count += 1
            print(" \(count): \(word)".lightCyan)
        }
    }
}
