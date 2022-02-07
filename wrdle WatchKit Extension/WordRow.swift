//
//  WordRow.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import SwiftUI


/// Displays a previously guess word.  Static and unchanging
struct WordRow: View {
    
    var guess: Guess
    var colors: [Color]
    var desiredSize: CGFloat
    var desiredSpacing: CGFloat
        
    var body: some View {
            
        let items = [GridItem](repeating: GridItem(.fixed(desiredSize), spacing: desiredSpacing, alignment: .center), count: guess.word.count)
                
        LazyVGrid(columns: items, alignment: .center, spacing: desiredSpacing, pinnedViews: [], content: {
            ForEach(0..<guess.word.count) {
                SquareLetter(letter: guess.word[$0], color: colors[$0], size: desiredSize)
            }
        })
    }
}

//struct WordRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WordRow(guess: "SIGNS", answer: "SMILE", rowIndex: 0, desiredSize: 35, desiredSpacing: 2);
//    }
//}



