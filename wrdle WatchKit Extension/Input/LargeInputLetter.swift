//
//  LargeInput.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/13/22.
//

import SwiftUI
import Combine

struct LargeInputLetter: View {
    
    @EnvironmentObject var model:WordModel
    let timerInterval:CGFloat = 1.5
    let partialTimerInterval:CGFloat = 0.1
    
    @Binding var guess:String // the guessed word
    let guessIndex:Int // which letter of guess this AnimatedFlipper is managing
    let size:CGFloat // The desired size of this flipper
    let colorPalette:ColorPalette // The color palette to use for the letters
    let alphabet:[String]
    @Binding var alphabetScore:[LetterScore]
    @Binding var isSelecting:Bool
    let focusNamespace:Namespace.ID
    
    @State private var number:Double   // index into alphabet that this flipper displays
    @State private var lastOffset:CGSize = .zero
    @State private var isMoving = false // flag to indicate that the number is changing -- either by gesture or crown
    @State private var isDragging = false // flag to indicate that a drag gesture has begun
    // If isMoving is true and isDragging is true, then number is being changed by gesture
    // If isMoving is true and isDragging is false, then number is being changed by crown rotation
    // isDragging should not be used for anything unless isMoving is true
    
    // managing the timer
    @State private var timerSubscription: Cancellable?
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)

    // init() allows setting of internal @State number
    init(
        guess:Binding<String>,
        guessIndex:Int,
        size:CGFloat,
        colorPalette:ColorPalette,
        alphabet:[String],
        alphabetScore:Binding<[LetterScore]>,
        isSelecting:Binding<Bool>,
        focusNamespace:Namespace.ID
    ) {
        self._guess = guess
        self.guessIndex = guessIndex
        self.size = size
        self.colorPalette = colorPalette
        self.alphabet = alphabet
        self._alphabetScore = alphabetScore
        self._isSelecting = isSelecting
        self.focusNamespace = focusNamespace
        
        let i = alphabet.firstIndex(of: guess.wrappedValue[guessIndex])
        self._number = State(initialValue: Double(i ?? 0)) // this will make a " " appear for the letter displayed
    }
   
    // convert the current number to it's corresponding letter
    var letter:String {
        if (number < 0) { return " " }
        var index = Int(number) % alphabet.count
        index = index < 0 ? (alphabet.count + index) : index
        return alphabet[index]
    }
    
    var body: some View {
        let scrollSpeed = 20.0
        
        GeometryReader { geo in
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                Color.clear
                    .frame(width: geo.size.width * 0.5)
                    .overlay(
                        MovingCounter(
                            index: number,
                            characters: alphabet,
                            alphabetScore: alphabetScore,
                            size: CGSize(width:size, height:size),
                            colorPalette: colorPalette,
                            isMoving: $isMoving
                        )
                    )
                    .focusable()
                    .digitalCrownRotation($number, from: 0, through: Double(alphabet.count-1), by: 0.5, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)
                    .prefersDefaultFocus(true, in: focusNamespace)
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(count: 3) {
                        model.invalidMessage = model.answer
                    }

            }
        }
        .font(Font.system(size:size))
        .onTapGesture(count: 1) {
            self.cancelTimer()
            withAnimation {
                isSelecting = false
            }
        }
        .gesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .local)
                .onChanged { gesture in
                    self.cancelTimer()

                    isSelecting = true

                    if(!isDragging) {
                        lastOffset = .zero
                    }

                    isDragging = true
                    isMoving = true

                    // calculate the new number and put it in the range of alphabet
                    // number is being observed (onChange), so make all calcs and then assign to number
                    var delta = (gesture.translation.height - lastOffset.height)
                    delta = min(delta, 1.0) // delta > 1 ? 1 : delta
                    delta = max(delta, -1.0) // delta < -1 ? -1 : delta
                    var newNumber = number - delta/scrollSpeed
                    newNumber = newNumber.truncatingRemainder(dividingBy: Double(alphabet.count))
                    newNumber = newNumber < 0 ? Double(alphabet.count) + newNumber : newNumber
                    number = newNumber
                    
                    lastOffset = gesture.translation // for the next gesture change
                    guess = updateGuess()
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.1)) { // see also animation complete below
                        self.number = round(self.number) // adjust number to land on the nearest whole number
                    }
                }
        )
        .onAppear {
            self.guess = updateGuess() // number (and therefore letter) may have been modified in the init(), so update guess on appear
            self.startTimer(timerInterval)
        }
        .onChange(of: number) { newValue in
            
            // This is the only place to know if number has been changed by the crown, so ignore number changes if by gesture.
            // This helps make the necessary appearance changes when the crown changes the number
            guard (!isDragging) else { return }
            
            isMoving = true
            
            self.cancelTimer()
            guess = updateGuess() // update the bound guess
            // either a drag end or crown movement will make number an integer

            if(floor(newValue) == newValue) { // is an integer value
                isMoving = false // will de-color the letter if it is fully visible
            }
            startTimer(timerInterval)
        }
        .onChange(of: guessIndex) {
            let newLetter = guess[$0]
            if(newLetter == " ") {
                number = -1.0 // reset to display a " "
            } else {
                let i = alphabet.firstIndex(of: newLetter)!
                number = Double(i)
            }
        }
        .onReceive(timer) { _ in
            self.cancelTimer()
            number = floor(number)
            guess = updateGuess()
            isMoving = false
            isDragging = false
            withAnimation {
                isSelecting = false // this will trigger the withGeometryEffect animation, and "dismiss" this view
            }
        }
        .onAnimationCompleted(for: number) {
            // reset moving and dragging, start the timer to dismiss self
            self.isDragging = false
            self.isMoving = false
            startTimer(timerInterval)
        }
        
    }
    
    // start the timer if it's not already running
    func startTimer(_ interval:CGFloat) {
        if self.timerSubscription == nil {
            self.timer = Timer.publish(every: interval, on: .main, in: .common)
            self.timerSubscription = self.timer.connect()
        }
    }
    
    // stop the timer
    func cancelTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }
    
    func updateGuess() -> String {
        let prefix = String(guess.prefix(self.guessIndex))
        let suffix = String(guess.suffix(guess.count-self.guessIndex-1))
        return prefix + letter + suffix
    }
}

//struct FooLargeInput: View {
//
//    @State var guess:Guess = Guess(word: "HELLO")
//    @State var guessIndex = 0
//    var size:CGFloat = 80
//    var colorPalette = ColorPalette(highContrast: true)
//    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
//    @State var alphabetScore = [LetterScore](repeating: .correct, count: 26)
//    @State var isSelecting = false
//
//    var body: some View {
//        LargeInput(
//            guess: $guess.word,
//            guessIndex: guessIndex,
//            size: size,
//            colorPalette: colorPalette,
//            alphabet: alphabet,
//            alphabetScore: $alphabetScore,
//            isSelecting: $isSelecting
//        )
//    }
//}
//
//struct LargeInput_Previews: PreviewProvider {
//    static var previews: some View {
//        FooLargeInput()
//    }
//}

