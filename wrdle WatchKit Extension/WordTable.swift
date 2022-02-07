//
//  WordTable.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import SwiftUI
import ClockKit
import WatchKit

let desiredSpacing: CGFloat = 1


struct WordTable: View {
    
    @Namespace private var geometryNamespace
    @Namespace private var focusNamespace
    
    @EnvironmentObject var model:WordModel
    @State var attempts: Int = 0
    
    @State private var useLargeInputRow = true
    @State private var showLargeInput = false
    
    @State private var isSelecting = false
    @State private var selectingIndex:Int = -1
    @State private var prefsGuess:String = ""
    
    var body: some View {
        
        let boxes = CGFloat(model.answer.count)
        let totalSpacing = (boxes - 1) * desiredSpacing
        
        ZStack {
            GeometryReader { geo in
                
                let size = (geo.size.width - totalSpacing) / boxes
                let items = ([GridItem](repeating: GridItem(.fixed(size)), count: model.guesses.count + 2)) // +2 for newrow/message and button
                let font = Font.system(size:size)
                ScrollView() {
                    ScrollViewReader { scrollView in
                        LazyHGrid(rows: items) {
                            ForEach(model.guesses, id:\.self) { guess in
                                WordRow(
                                    guess: guess,
                                    colors: model.score2Colors(guess.score),
                                    desiredSize: size,
                                    desiredSpacing: desiredSpacing
                                )
                                    .onTapGesture(count: 2) {
                                        model.currentGuess = guess.word
                                    }
                                    .onLongPressGesture(minimumDuration: 0.1) {
                                        prefsGuess = guess.word
                                    }
                            }
                            
                            if(model.gameOver) {
                                GameOver(model: model)
                            } else {
                                GuessAndButton(
                                    model: model,
                                    size: size,
                                    attempts:$attempts,
                                    isSelecting: $isSelecting,
                                    selectingIndex: $selectingIndex,
                                    useLargeInputRow:useLargeInputRow,
                                    namespace: geometryNamespace
                                )
                            }
                        }
                        .onChange(of: model.guesses) { guesses in
                            scrollView.scrollTo(99)
                        }
                    }
                    .font(font)
                }
                .allowsHitTesting(useLargeInputRow && !isSelecting)
                
                if(useLargeInputRow && isSelecting) {
                    LargeInputLetter(
                        guess: $model.currentGuess,
                        guessIndex: selectingIndex,
                        size: 2.25 * size,
                        colorPalette: model.colorPalette,
                        alphabet: model.alphabet,
                        alphabetScore: $model.alphabetScore,
                        isSelecting: $isSelecting,
                        focusNamespace: focusNamespace
                    )
                        .matchedGeometryEffect(id:"Square\(selectingIndex)", in:geometryNamespace, properties: .position)
                        .onDisappear {
                            selectingIndex = -1
                        }
                }
                
                if(model.userWon) {
                    let _ = WKInterfaceDevice.current().play(.success)
                    Fireworks(word: model.answer)
                }
                
                if(prefsGuess != "") {
                    Preferences(initialGuess: $prefsGuess)
                }
                
                
            }.focusScope(focusNamespace)
        }
    }
    
    struct GuessAndButton: View {
        
        var model:WordModel
        let size:CGFloat
        @Binding var attempts:Int
        @Binding var isSelecting:Bool
        @Binding var selectingIndex:Int
        let useLargeInputRow:Bool
        let namespace:Namespace.ID
        
        var body: some View {
            
            if(useLargeInputRow) {
                LargeInputRow(
                    numberOfItems: model.answer.count,
                    alphabet: model.alphabet,
                    size: size,
                    desiredSpacing: desiredSpacing,
                    attempts:$attempts,
                    isSelecting: $isSelecting,
                    selectingIndex: $selectingIndex,
                    namespace: namespace
                )
            } else {
                SpinnerInputRow(
                    numberOfItems: model.answer.count,
                    alphabet: model.alphabet,
                    size: size,
                    desiredSpacing: desiredSpacing,
                    attempts:$attempts
                )
            }
            Button(action: {
                
                if(model.isValidGuess(model.currentGuess)) {
                    model.addGuess(model.currentGuess)
                } else {
                    withAnimation(.default) {
                        self.attempts += 1
                    }
                    WKInterfaceDevice.current().play(.retry)
                }
                
            }) {
                Text("Enter")
                    .frame(minWidth: size * 4)
                    .font(.system(.headline))
            }
            .padding(.top, 20)
            .id(99)
            
        }
    }
    
    struct GameOver: View {
        
        var model:WordModel
        var body: some View {
            if(model.userWon) {
                Text(model.winningMessage())
                    .font(.system(.headline))

            } else {
                Text(model.answer)
                    .font(.system(.headline))
            }
            
            Button {
                model.newGame()
            } label: {
                Text("Play Again")
            }
            .font(.system(.headline))
        }
    }
    
    struct Preferences:View {
        @Binding var initialGuess:String
        
        @State private var offset = CGFloat.zero
        @State private var startX = CGFloat.zero
        @State private var endX = CGFloat.zero
        @State private var showX = CGFloat.zero
        
        func dismiss() {
            withAnimation {
                offset = endX
            }
        }
        
        var body: some View {
            
            GeometryReader { geo in

                VStack{
                    if( UserDefaults.standard.string(forKey: "InitialGuess") == nil || UserDefaults.standard.string(forKey: "InitialGuess") != initialGuess) {
                        Text("Set \(initialGuess) as initial guess?")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.black)
                            .background(Color.clear)
                            .font(.headline)
                            
                        HStack {
                            Button {
                                UserDefaults.standard.set(initialGuess, forKey: "InitialGuess")
                                dismiss()
                            } label: { Text("Yes") }
                            
                            Button {
                                dismiss()
                            } label: { Text("No") }
                        }
                        .padding()
                        .foregroundColor(.white)
                        .buttonStyle(BorderedButtonStyle(tint: Color.blue.opacity(255)))
                        
                    } else if(UserDefaults.standard.string(forKey: "InitialGuess") == initialGuess) {
                        Text("Remove \(initialGuess) as initial guess?")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.black)
                            .background(Color.clear)
                            .font(.headline)
                        HStack {
                            Button {
                                UserDefaults.standard.removeObject(forKey: "InitialGuess")
                                dismiss()
                            } label: { Text("Yes") }
                            
                            Button {
                                dismiss()
                            } label: { Text("No") }

                        }
                        .padding()
                        .foregroundColor(.white)
                        .buttonStyle(BorderedButtonStyle(tint: Color.blue.opacity(255)))
                    }
                }
                .background(
                    RoundedRectangle(cornerSize: CGSize(width: 5, height:5))
                        .foregroundColor(Color(UIColor.lightGray))
                )
                .padding()
                .offset(x:offset, y:0)
                .onAppear {
                    startX = geo.size.width
                    endX = -geo.size.width
                    showX = 0
                    offset = startX
                    withAnimation {
                        offset = showX
                    }
                }
                .onDisappear {
                    offset = startX
                }
                .onAnimationCompleted(for: offset) {
                    if(offset == endX) {
                        offset = startX
                        initialGuess = ""
                    }
                }
            }
            
        }
    }
}


//struct Foo2:View {
//    @State var model = WordModel()
//
//    var body: some View {
//        WordTable()
//    }
//}
//
//struct WordTable_Previews: PreviewProvider {
//
//    static var previews: some View {
//        Foo2()
//    }
//}



