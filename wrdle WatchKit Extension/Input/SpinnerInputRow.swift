//
//  WordInputRow.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/6/22.
//

import SwiftUI

struct SpinnerInputRow: View {
    
    @EnvironmentObject var model:WordModel
    
    var numberOfItems:Int
    var alphabet:[String]
    var size:CGFloat
    var desiredSpacing:CGFloat
    @Binding var attempts:Int
    
    @State private var degrees:CGFloat = 90
    
    var body: some View {
        
        let items = [GridItem](repeating: GridItem(.fixed(size), spacing: desiredSpacing, alignment: .center), count: numberOfItems)
        
        ZStack{
            
            LazyVGrid(columns: items, alignment: .center, spacing: desiredSpacing*10, pinnedViews: [], content: {
                ForEach(0..<numberOfItems) {
                    AnimatedLetterFlipper(
                        guess: $model.currentGuess,
                        guessIndex: $0,
                        size: size,
                        colorPalette: model.colorPalette,
                        alphabet: alphabet,
                        alphabetScore: $model.alphabetScore
                    )
                }
            })
                .modifier(Shake(animatableData: CGFloat(attempts)))
            
            UserMessage(message: $model.invalidMessage, delay: 1.5)

        }
    }
}


//struct FooSpinnerInputRow: View {
//    @State var guess:String = "SUITE"
//    @State var attempts:Int = 0
//    var body: some View {
//        SpinnerInputRow(size: 40, desiredSpacing: 2, attempts: $attempts)
//    }
//}
//
//struct SpinnerInputRow_Previews: PreviewProvider {
//    static var previews: some View {
//        FooSpinnerInputRow()
//    }
//}

