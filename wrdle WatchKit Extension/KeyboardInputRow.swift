//
//  WordInputRow.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/6/22.
//

import SwiftUI

struct KeyboardInputRow: View {
    
    @EnvironmentObject var model:WordModel
    
    //    @Binding var guess:String
    @State var size:CGFloat
    @State var desiredSpacing:CGFloat
    @Binding var attempts:Int
    
    
    var body: some View {
        
        
        ZStack {
            
            WordRow(
                guess: model.$currentGuess,
                checkGuess: false,
                desiredSize: size,
                desiredSpacing: desiredSpacing
            )
                .padding(.top, -desiredSpacing)
            
            TextField("", text: model.$currentGuess)
                .background(Color.clear)
                .opacity(0.1666)
                .textCase(.uppercase)
                .onChange(of: model.currentGuess) { newValue in
                    model.currentGuess = String(newValue.prefix(5)).uppercased()
                }
                .textInputAutocapitalization(.characters)
        }
        .modifier(Shake(animatableData: CGFloat(attempts)))
    }
}


struct FooKeyboardInputRow: View {
    @State var guess:String = "SUITE"
    @State var attempts:Int = 0
    var body: some View {
        SpinnerInputRow(
            //            guess: $guess,
            size: 40, desiredSpacing: 2, attempts: $attempts)
    }
}

struct KeyboardInputRow_Previews: PreviewProvider {
    static var previews: some View {
        FooKeyboardInputRow()
    }
}


