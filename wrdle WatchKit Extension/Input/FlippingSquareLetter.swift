//
//  FlippingSquareLetter.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import SwiftUI


struct FlippingSquareLetter: View {
    
    @Binding var guess:String
    var guessIndex:Int
    var size: CGFloat
    var correct: String
    var wrongPosition: [String]
    var notInWord:[String]
    var colorPalette:ColorPalette
    @State private var letterIndex:Int = 0
    
    let alphabet = " ABCDEFGHIJKLMNOPQRSTUVWXYZ".map({String($0)})
    
    /// Returns the letter of the alphabet at the given index.  The index is first normalized betwen 0 and 26
    /// - Parameter i: The index of the desired character of the alphabet (including space)
    /// - Returns: Letter of the alphabet
    func getLetter(_ i:Int) -> String {
        var index = i % alphabet.count
        index = index < 0 ? (alphabet.count + index) : index
        return alphabet[index]
    }
    
    @State private var goingUp:Bool = true
    @State private var lastOffset:CGSize = .zero
    @State private var offsetHeight:CGFloat = .zero
    
    @State private var offsetFactor:CGFloat = 5
    @State private var currentOffset = CGSize.zero
    @State private var scaleValue = 1.0
    
    /// Returns the color associated with the "correctness" of the letter of the alphabet
    /// - Parameter index: index into <space>A-Z
    /// - Returns: Color
    func colorFor(index:Int) -> Color {
                
        var i = index % alphabet.count
        i = i < 0 ? (alphabet.count + i) : i
        let letter = alphabet[i]
        var color = colorPalette.notEvaluated
        if (letter == correct) {
            color = colorPalette.correct
        } else if (wrongPosition.contains(letter)) {
            color = colorPalette.wrongPosition
        } else if (notInWord.contains(letter)) {
            color = colorPalette.notInWord
        }
//        print("correct: \(correct) wrongPos: \(wrongPosition) not: \(notInWord)")
//        print("colorFor: \(index)->\(i) \(color)")

        return color
    }
    
    var body: some View {
        
        VStack {
//            let _ = print("FSL size: \(size)")
            let letterIndex = alphabet.firstIndex(of: guess[guessIndex])!
            ForEach((letterIndex-38)..<(letterIndex+39), id: \.self) { index in
                
                FlippingSquare(
                    letter: getLetter(index),
                    color: (letterIndex == index && dragStarted) ? colorPalette.notEvaluated : colorFor(index:index),
                    size: size
                )
                    .offset(x: 0, y:currentOffset.height * offsetFactor)
                /// allow hits on all squares to combat a weird bug where the 'spinner' is getting stcuk between letters
                // .allowsHitTesting(letterIndex == self.letterIndex)
                    .gesture(drag)
            }
        }
        .scaleEffect(scaleValue)
        //.frame(width: size * 1.1 * scaleValue, height: size * 1.1 * scaleValue, alignment: .center)
        .frame(width:size, height: size, alignment: .center)
        .clipped()
    }
    
    @State private var dragStarted = true
    /// Drag gesture used to flip the letters
    var drag: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { gesture in
                
                dragStarted = false // will color-ize a currently selected letter when user spins away from it
                
                self.currentOffset = gesture.translation
                
                offsetHeight = self.currentOffset.height
                
                if(lastOffset.height > self.currentOffset.height) {
                    goingUp = true
                } else if (lastOffset.height < self.currentOffset.height) {
                    goingUp = false
                }
                lastOffset = self.currentOffset
                scaleValue = 1.25
            }
            .onEnded { _ in
                
                let foo = size/offsetFactor
                var wholeSquares = (offsetHeight/foo).rounded(.towardZero)
                let partialSquares = (offsetHeight/foo) - CGFloat(wholeSquares)
                // let partials = offsetHeight.truncatingRemainder(dividingBy: foo)
                // print(offsetHeight, size, wholeSquares, partialSquares, partials)
                
                wholeSquares += partialSquares > 0.75 ? 1 : 0
                wholeSquares -= abs(partialSquares) > 0.75 ? 1 : 0
                
                // print("wholeSquares", wholeSquares)
                
                self.letterIndex -= Int(wholeSquares)
                
                //                                print("before >\(guess)< \(guess.count)")
                let letter = getLetter(self.letterIndex)
                
                let prefix = String(guess.prefix(self.guessIndex))
                let suffix = String(guess.suffix(guess.count-self.guessIndex-1))
                
                guess = prefix + letter + suffix
                // print(">\(prefix)< >\(letter)< >\(suffix)<")
                // print("after: >\(guess)< \(guess.count)")
                
                self.currentOffset = .zero
                offsetHeight = 0
                scaleValue = 1.0
                dragStarted = true
            }
    }
}


struct FlippingSquare: View {
    var letter:String
    var color: Color
    var size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .foregroundColor(color)
            .frame(width: size, height:size, alignment: .center)
            .border(Color.appGray, width: color == .clear ? 1 : 0)
            .overlay(
                Text(letter)
                    .font(.system(size: size))
                    .fixedSize(horizontal: true, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: size, height: size, alignment: .center)
            )
    }
}

struct FooFlippingSquareLetter:View {
    @State var guess = "SUITE"
    var colorPalette = ColorPalette(highContrast: false)
    var body: some View {
        FlippingSquareLetter(
            guess: $guess,
            guessIndex:0,
            size:40,
            correct: "A",
            wrongPosition: ["D", "E"],
            notInWord: ["X", "Y", "Z"],
            colorPalette: colorPalette
        )
    }
}

struct FlippingSquareLetter_Previews: PreviewProvider {
    static var previews: some View {
        FooFlippingSquareLetter()
    }
}


