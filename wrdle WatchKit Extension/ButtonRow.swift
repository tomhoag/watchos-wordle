//
//  ButtonRow.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/5/22.
//

import SwiftUI
import ClockKit

struct ButtonRow: View {
    

    var rowIndex:Int
    var desiredSize:CGFloat
    var desiredSpacing: CGFloat
    
    var body: some View {
        let items = [
            GridItem(.fixed(desiredSize), spacing: desiredSpacing, alignment: .center),
            GridItem(.fixed(desiredSize), spacing: desiredSpacing, alignment: .center),
            GridItem(.fixed(desiredSize), spacing: desiredSpacing, alignment: .center),
            GridItem(.fixed(desiredSize), spacing: desiredSpacing, alignment: .center),
            GridItem(.fixed(desiredSize), spacing: desiredSpacing, alignment: .center)
        ]
        
        LazyVGrid(columns: items, alignment:.center, spacing: desiredSpacing, pinnedViews: [], content: {
            ForEach(0..<5) { index in
                Button(action: {
                    print("woot", index)
                }){
                    Text("_")
                }
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .frame(width: desiredSize, height:desiredSize, alignment: .center)
                        .foregroundColor(Color.clear)
                        .border(Color.gray)
                )
                .buttonStyle(PlainButtonStyle())
            }
        })
    }
}

//struct ButtonRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ButtonRow(rowIndex: 0, desiredSize: 38, desiredSpacing: 2)
//    }
//}
