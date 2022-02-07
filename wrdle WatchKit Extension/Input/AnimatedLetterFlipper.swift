//
//  AnimatedFlipper.swift
//  AnimatedFlipper
//
//  Created by Tom on 1/9/22.
//

import SwiftUI


struct AnimatedLetterFlipper: View {
    
    @Binding var guess:String // the guessed word 
    let guessIndex:Int // which letter of guess this AnimatedFlipper is managing
    let size:CGFloat // The desired size of this flipper
    let colorPalette:ColorPalette // The color palette to use for the letters
    let alphabet:[String]
    @Binding var alphabetScore:[LetterScore]
    
    @State private var number:Double   // index into alphabet that this flipper displays
    @State private var lastOffset:CGSize = .zero
    @State private var isDragging = false // flag to indicate that a drag gesture is presently happening (or not)
    @State private var isAnimating = false // flag to indicate that the view is currently animating
    @State private var isFirstDrag = true // flag to indicate that the next drag gesture will be the first since the view was last redrawn

    init(guess:Binding<String>,
         guessIndex:Int,
         size:CGFloat,
         colorPalette:ColorPalette,
         alphabet:[String],
         alphabetScore:Binding<[LetterScore]>
    ) {
        self._guess = guess
        self.guessIndex = guessIndex
        self.size = size
        self.colorPalette = colorPalette
        self.alphabet = alphabet
        self._alphabetScore = alphabetScore

        let i = alphabet.firstIndex(of: guess.wrappedValue[guessIndex])
        self._number = State(initialValue: Double(i ?? -1)) // this will make a " " appear for the letter displayed
    }
    
    var letter:String {
        if (number < 0) { return " "}
        var index = Int(number) % alphabet.count
        index = index < 0 ? (alphabet.count + index) : index
        return alphabet[index]
    }
    
    var body: some View {
        let scrollSpeed = 20.0

        VStack {
            Color.clear
        }        
        .overlay(
            MovingCounter(
                index: number,
                characters: alphabet,
                alphabetScore: alphabetScore,
                size: CGSize(width:size, height:size),
                colorPalette: colorPalette,
                isMoving: $isDragging
            )
        )
        .gesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .local)
                .onChanged { gesture in
//                    guard(!isAnimating) else { return }
                    if(isFirstDrag) {
                        number = 0 // if this is the first time this spinner has been dragged, change the index to represent "A"
                    }
                    isFirstDrag = false // no longer first drag
                    
                    if(!isDragging) {
                        lastOffset = .zero
                    }
                    isDragging = true
                    
                    // calculate the new number and put it in the range of alphabet
                    // number is being observed, so make all calcs and then assign to number
                    var newNumber = number - (gesture.translation.height - lastOffset.height)/scrollSpeed
                    newNumber = newNumber.truncatingRemainder(dividingBy: Double(alphabet.count))
                    newNumber = newNumber < 0 ? Double(alphabet.count) + newNumber : newNumber
                    number = newNumber
                    
                    lastOffset = gesture.translation
                }
                .onEnded { _ in
                    //withAnimation(.interpolatingSpring(mass: 1, stiffness: 500, damping: 10, initialVelocity: 4) ) {
                    withAnimation(.easeOut(duration: 0.1)) {
                        isAnimating = true
                        self.number = round(self.number) // adjust number to land on the nearest whole number
                    }

                    // update the bound guess
                    let prefix = String(guess.prefix(self.guessIndex))
                    let suffix = String(guess.suffix(guess.count-self.guessIndex-1))
                    guess = prefix + letter + suffix
                }
        )
        .onAnimationCompleted(for: number) {
            self.isAnimating = false
            self.isDragging = false
        }
        .onChange(of: guess) { newValue in
            let newLetter = newValue[guessIndex]
            if(newLetter == " ") {
                isFirstDrag = true // next drag is the first drag
                number = -1.0 // reset to display a " "
            } else {
                isFirstDrag = false
                let i = alphabet.firstIndex(of: newLetter)!
                number = Double(i)
            }
        }
    }
}

extension View {

    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
}

/// An animatable modifier that is used for observing animations for a given animatable value.
struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    /// While animating, SwiftUI changes the old input value to the new target value using this property. This value is set to the old value until the animation completes.
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the animation starts. During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        return content
    }
}
