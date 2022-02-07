//
//  SquareLetter.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import SwiftUI

struct SquareLetter: View {
    var letter: String
    var color: Color
    var size: CGFloat
    
    var body: some View {
        Text(letter)
            .fixedSize(horizontal: true, vertical: true)
            .multilineTextAlignment(.center)
            .padding()
            .frame(width: size, height: size, alignment: .center)
            .background(Square(color: color, size: size))
    }
}

struct Square: View {
    var color: Color
    var size: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .frame(width: size, height:size, alignment: .center)
            .foregroundColor(color)
            .border(Color.gray)
    }
}

//struct SquareLetter_Previews: PreviewProvider {
//    static var previews: some View {
//        SquareLetter(letter: "A", color: .red, size: 80)
//    }
//}


