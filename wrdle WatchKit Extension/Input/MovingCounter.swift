//
//  MovingCounter.swift
//  Example13
//
//  Created by Tom on 1/10/22.
//

import SwiftUI
import UIKit

struct MovingCounter: View {
    
    let index: Double
    let characters: [String]
    let alphabetScore:[LetterScore]
    let size:CGSize
    let colorPalette:ColorPalette
    @Binding var isMoving:Bool
    
    var body: some View {
        Text("0")
            .frame(width: size.width, height: size.height, alignment: .center)
            .modifier(
                MovingCounterModifier(
                    index: index,
                    alphabet: characters,
                    alphabetScore: alphabetScore,
                    size:size,
                    colorPalette:colorPalette,
                    isMoving: $isMoving
                )
            )
    }
    
    struct MovingCounterModifier: AnimatableModifier {
        
        var index: Double
        let alphabet: [String]
        let alphabetScore: [LetterScore]
        let size:CGSize
        let colorPalette:ColorPalette
        @Binding var isMoving: Bool
        
        var animatableData: Double {
            get { index }
            set { index = newValue }
        }
        
        func letterFor(_ index:Int) -> String {
            if(index < 0) { return " "}
            var i = index % alphabet.count
            i = i < 0 ? (alphabet.count + i) : i
            return alphabet[i]
        }
        
        /// Using the colorPalette, returns the color that corresponds to the "correct-ness" of the letter
        /// - Parameter index: <#index description#>
        /// - Returns: <#description#>
        func colorFor(_ index:Double) -> Color {
            if (!isMoving) { return colorPalette.notEvaluated }
            var i = Int(index) % alphabet.count
            i = i < 0 ? alphabet.count + i : i
            return colorPalette.colorForState(alphabetScore[i])
        }
        
        func body(content: Content) -> some View {

            let n = self.index + 1 // why??
            let unitDigitOffset: CGFloat = getOffsetForIndex(n)
            
            let letterIndex = [n - 2, n - 1, n + 0, n + 1, n + 2].map { normalize($0) }

            return HStack(alignment: .top, spacing: 0) {
                VStack {
                    ForEach(0..<5, id:\.self) {
                        Text("\(letterFor(letterIndex[$0]))")
                            .frame(width: size.width, height: size.height, alignment: .center)
                            .background(colorFor(Double(letterIndex[$0])))
                            .padding(.all, -2.5)
                    }
                }
                .modifier(ShiftEffect(pct: unitDigitOffset))
                
            }
            .clipShape(ClipShape(cornerRadius: 0))
            .overlay(BackShape(cornerRadius: 0)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color.gray)) // border
            .background(BackShape(cornerRadius: 0)
                            .fill(Color.clear)) // background
            
        }
        
        /// Normalize number in the range 0..alphabet.count and convert to Int
        /// - Parameter number: number to normalize
        /// - Returns: Int in the range of 0..alphabet.count
        func normalize(_ number: Double) -> Int {
            return Int(number) % alphabet.count
        }
        
        /// Returns the height offset for the letter @ number position
        /// - Parameter number: the number/letter to offset
        /// - Returns: the height offset
        func getOffsetForIndex(_ number: Double) -> CGFloat {
            return 1 - CGFloat(number - Double(Int(number)))
        }
        
    }
    
    struct BackShape: Shape {
        var cornerRadius:CGFloat
        let numberOfChars = 5.0
        
        func path(in rect: CGRect) -> Path {
            let displaySize = CGSize(width: rect.height/numberOfChars, height: rect.height/numberOfChars)
            let h = displaySize.height
            let w = displaySize.width
            var p = Path()
                    
            let cr = CGRect(x: (rect.width - w)/2.0, y: (rect.height - h)/2.0, width: displaySize.width, height: displaySize.height) // center width x height CGRect inside rect
            p.addRoundedRect(in: cr, cornerSize: CGSize(width: cornerRadius, height: cornerRadius)) // draw it
            return p
        }
    }
    
    struct ClipShape: Shape {
        var cornerRadius:CGFloat
        let numberOfChars:CGFloat = 5
        
        func path(in rect: CGRect) -> Path {
            let displaySize = CGSize(width: rect.height/numberOfChars, height: rect.height/numberOfChars)
            
            let h = displaySize.height
            let w = displaySize.width
            var p = Path()
            
            let cr = CGRect(x: (rect.width - w)/2.0, y: (rect.height - h) / 2.0, width: displaySize.width, height: displaySize.height)
            p.addRoundedRect(in: cr, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
            
            return p
        }
    }
    
    struct ShiftEffect: GeometryEffect {
        var pct: CGFloat = 1.0
        let numberOfCharacters:CGFloat = 5
        func effectValue(size: CGSize) -> ProjectionTransform {
            return .init(.init(translationX: 0, y: (size.height / numberOfCharacters) * pct))
        }
    }
    
    
   
}

//struct MovingCounter_Previews: PreviewProvider {
//    static var previews: some View {
//        MovingCounter()
//    }
//}
