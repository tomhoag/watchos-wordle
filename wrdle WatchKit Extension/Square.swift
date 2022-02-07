//
//  Square.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import SwiftUI

let squareSize: CGFloat = 30

struct Square: View {
    var color: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .frame(width: squareSize, height:squareSize, alignment: .center)
            .foregroundColor(color)
            .border(Color.gray)
    }
}

// Our preview
struct ComponentsSquares_Previews: PreviewProvider {
    static var previews: some View {
        // Colours
        let colors = [
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            
            Color.white,
            Color.white,
            Color.white,
            Color.white,
            Color.white
            
        ]

        // This will be our desired spacing we want for our grid
        // If you want the grid to be truly square you can just set this to 'squareSize'
        let spacingDesired: CGFloat = 5

        // These are our grid items we'll use in the 'LazyHGrid'
        let rows = [
            GridItem(.fixed(squareSize), spacing: spacingDesired, alignment: .center),
            GridItem(.fixed(squareSize), spacing: spacingDesired, alignment: .center),
            GridItem(.fixed(squareSize), spacing: spacingDesired, alignment: .center),
            GridItem(.fixed(squareSize), spacing: spacingDesired, alignment: .center),
            GridItem(.fixed(squareSize), spacing: spacingDesired, alignment: .center),
            GridItem(.fixed(squareSize), spacing: spacingDesired, alignment: .center)

        ]

        // We then use the 'spacingDesired' in the grid
        LazyHGrid(rows: rows, alignment: .center, spacing: spacingDesired, pinnedViews: [], content: {
            ForEach(0 ..< colors.count) { colorIndex in
                Square(color: colors[colorIndex])
            }
        })
    }
}
