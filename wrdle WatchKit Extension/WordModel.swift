//
//  WordModel.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import Foundation
import WatchKit
import SwiftUI

struct Guess:Equatable, Hashable {
    static func == (lhs: Guess, rhs: Guess) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    var id:String
    var word:String
    var score:[LetterScore]
    
    init(word: String) {
        self.word = word
        self.score = [LetterScore](repeating: .notEvaluated, count: 5)
        self.id = UUID().uuidString
    }
}

enum LetterScore: Int, CaseIterable {
    case notEvaluated = 0
    case notInWord = 1
    case wrongPosition = 2
    case correct = 3
}

struct ColorPalette {
    
    var highContrast = false
    private var colors:[Color]
    
    var notEvaluated:Color { return colors[LetterScore.notEvaluated.rawValue] }
    
    init(highContrast:Bool) {
        
        self.highContrast = highContrast
        if(highContrast) {
            colors = [ Color.black, Color.appGray, Color.appBlue, Color.appRed ]
        } else {
            colors = [ Color.black, Color.appGray, Color.appYellow, Color.appGreen ]
        }
    }
    
    func colorForState(_ state:LetterScore) -> Color {
        return colors[ state.rawValue ]
    }
}


class WordModel:ObservableObject {

    @Published var debug:Bool = false
    
    private let MAX_GUESS_COUNT:Int = 6
    private let winnerMessages = ["Brilliant", "Spectacular", "Grand", "Great", "Good", "Phew"]
    func winningMessage() -> String { return winnerMessages[guesses.count - 1] }

    let highContrast = false //TODO: Add to app settings
    
    var colorPalette:ColorPalette { return ColorPalette(highContrast: highContrast) }
    
    var answer: String = ""
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }

    @Published var currentGuess:String = String(repeating: " ", count:5)
    @Published var guesses:[Guess] = []
    @Published var gameOver: Bool = false
    @Published var userWon: Bool = false
    @Published var alphabetScore:[LetterScore] = []
    @Published var invalidMessage:String = ""

    private lazy var words:[String] = { loadFile("words") }()
    private lazy var dictionary:[String] = { loadFile("dictionary") }()
    
    func loadFile(_ name:String) -> [String] {
        if let filepath = Bundle.main.path(forResource:name, ofType:"txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                var words = contents.components(separatedBy: "\n")
                words = words.map { $0.uppercased() }
                return words
            } catch {
                print("Could not load \(name).txt")
                return ["nolod"]
            }
        } else {
            print("File missing!")
            return ["filem"]
        }
    }
    
    init() {
        newGame()
    }
        
    func score(guess: String, answer:String) -> [LetterScore] {
        var score = [LetterScore](repeating: .notEvaluated, count: answer.count)
        var usedIndicies:[Int] = []
        
        // find correctly positioned letters
        for i in 0..<answer.count {
            if(guess[i] == answer[i]) {
                score[i] = .correct
                usedIndicies.append(i)
            }
        }
        
        // find incorrectly positioned letters
        for i in 0..<answer.count {
            if(score[i] == .notEvaluated) {
                let foundIndicies = answer.indicesOf(string: guess[i])
                
                let availableIndicies = Array(Set(foundIndicies).subtracting(usedIndicies))
                if(availableIndicies.count > 0)  {
                    score[i] = .wrongPosition
                    for j in 0..<availableIndicies.count {
                        usedIndicies.append(availableIndicies[j])
                    }
                }
            }
        }
        
        // anything left that is .notEvaluated is .notInWord
        score = score.map { return $0 == .notEvaluated ? .notInWord : $0 }
        
        return score
    }
    
    func abcScore() -> [String] {
        var green = ""
        var yellow = ""
        var gray = ""
        for i in 0..<alphabetScore.count {
            if(alphabetScore[i] == .correct) {
                green.append(alphabet[i])
            } else if(alphabetScore[i] == .wrongPosition) {
                yellow.append(alphabet[i])
            } else if(alphabetScore[i] == .notInWord) {
                gray.append(alphabet[i])
            }
        }
        return [green, yellow, gray]
    }
    
    /// Update the alphabet score by evaluating the words that have been guessed against the answer:
    /// 1. Letters in any guess that are in the correct position are scored .correct for the alphabet
    /// 2. Letters in any guess that are in the wrong position are scored .wrongPosition for the alphabet
    /// 3. Letters in any guess that do not appear in the answer are scored .notInWord
    ///  Once a letter in the alphabet has been scored, its score does not change (unless this function is invoked
    ///  again with a new set of guesses)
    func updateAlphabetScore() {
        if let guess = guesses.last?.word {
            for i in 0..<guess.count {
                let letter = guess[i]
                if let letterIndex = alphabet.firstIndex(of:letter) {
                    // find letters in the guess that are in the correct position
                    if(letter == answer[i]) {  // correct letter, correct position
                        alphabetScore[letterIndex] = .correct
                    } else if let _ = answer.firstIndex(of: Character(letter)) { // guess letter in answer
                        if alphabetScore[letterIndex] != .correct { // not previously marked as correct
                            alphabetScore[letterIndex] = .wrongPosition
                        }
                    } else { // guess letter not in answer
                        if(!([.correct, .wrongPosition].contains(alphabetScore[letterIndex]))) {
                            alphabetScore[letterIndex] = .notInWord
                        }
                    }
                }
            }
        }
    }
    
    /// Reset everything, select a new word and start a new game
    func newGame() {

        guesses = []
        currentGuess = String(repeating: " ", count:5)
        gameOver = false
        userWon = false
        alphabetScore = [LetterScore](repeating: .notEvaluated, count: alphabet.count)
        invalidMessage = ""
        
        var tries = 0
        self.answer = words.randomElement()!
        while(tries < 4 && !self.answer.isAlpha() && self.answer.count != 0) {
            self.answer = words.randomElement()!.uppercased()
            tries += 1
        }
        if(tries == 4) {
            self.answer = "NOTAV"
        }
        
        print("Answer: ", self.answer)
        
        if let initialGuessWord = UserDefaults.standard.string(forKey: "InitialGuess") {
            self.currentGuess = initialGuessWord
        }
        
        if(debug) {
            addGuess("ADIEU")
            self.currentGuess = self.answer
        }
    }
    
    /// Returns true if the guess meets the requirements of a valid guess
    /// - Parameter guess: The guess
    /// - Returns: True if guess is valid; false otherwise
    func isValidGuess(_ guess:String) -> Bool {
        
        var message = ""
        
        if( guess.contains(" ") || guess.count < answer.count) {
            message = "Not enough letters"
        }
        
        else if(!guess.isAlpha()) {
            message = "Use only A-Z"
        }
        
        else if(!words.contains(guess) && !dictionary.contains(guess)) {
            message = "Not in word list"
        }
        
        if(message != "") {
            self.invalidMessage = message
            return false
        }
        
        return true
    }
   
    func addGuess(_ word:String) {
        var guess = Guess(word: word)
        guess.score = self.score(guess: guess.word, answer: answer)
        guesses.append(guess)
        
        updateAlphabetScore()
        
        currentGuess = String(repeating: " ", count:5)
        
        // Is the game over?
        if(guess.word.uppercased() == answer.uppercased() || guesses.count == MAX_GUESS_COUNT) {
            gameOver = true
        }
        if(gameOver) {
            userWon =  (guess.word.uppercased() == answer.uppercased()) ? true : false
        }
    }
    
    /// Convert an array of letter scores to their associated color palette colors
    /// - Parameter score: an array of LetterScores
    /// - Returns: an array of Colors
    func score2Colors(_ score: [LetterScore]) -> [Color] {
        return score.map { colorPalette.colorForState($0) }
    }
}

extension String {

    subscript(characterIndex: Int) -> Self {
        return String(self[index(startIndex, offsetBy: characterIndex)])
    }
    
    func isAlpha() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil && self != ""
    }

    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

extension Color {
    
    static let appGreen = Color("AppGreen")
    static let appYellow = Color("AppYellow")
    static let appGray = Color("AppGray")
    static let appRed = Color("AppRed")
    static let appBlue = Color("AppBlue")
    
}

extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }
}
