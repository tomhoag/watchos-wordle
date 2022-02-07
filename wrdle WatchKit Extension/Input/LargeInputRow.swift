//
//  LargeInputRow.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/13/22.
//

import SwiftUI

struct LargeInputRow: View {
    @EnvironmentObject var model:WordModel
    
    var numberOfItems:Int
    var alphabet:[String]
    var size:CGFloat
    var desiredSpacing:CGFloat
    @Binding var attempts:Int
    @Binding var isSelecting:Bool
    @Binding var selectingIndex:Int
    let namespace:Namespace.ID
    
    @State private var degrees:CGFloat = 90
    
    
    var body: some View {
        
        let items = [GridItem](repeating: GridItem(.fixed(size), spacing: desiredSpacing, alignment: .center), count: numberOfItems)
        let colors = [Color](repeating: .clear, count:5)
        
        ZStack{
            
            LazyVGrid(columns: items, alignment: .center, spacing: desiredSpacing, pinnedViews: [], content: {
                if(!isSelecting) {
                    ForEach(0..<numberOfItems) { index in

                        SquareLetter(
                            letter: model.currentGuess[index],
                            color: colors[index],
                            size: size
                        )
                            .matchedGeometryEffect(id: "Square\(index)", in: namespace, properties: .position)
                            .contentShape(Rectangle())
                            .onTapGesture(count: 1) {
                                selectingIndex = index
                                withAnimation {
                                    isSelecting = true
                                }
                            }
                    }
                   
                } else {
                    ForEach(0..<numberOfItems) { index in
                        if(index != selectingIndex) {
                            SquareLetter(
                                letter: model.currentGuess[index],
                                color: colors[index],
                                size: size
                            )
                        } else {
                            Color.clear
                                .frame(width: size, height: size, alignment: .center)
                        }
                    }
                }
            })
                
                .modifier(Shake(animatableData: CGFloat(attempts)))
            
            UserMessage(message: $model.invalidMessage, delay: 1.5)
        }
    }
        
}

struct LargeInputRow_Previews: PreviewProvider {

    static var previews:some View {
        FooContentView()
    }
}



struct FooContentView: View {
    @StateObject var model = WordModel()
    
    var body: some View {
        FooLargeInputRow().environmentObject(model)
    }
}

struct FooLargeInputRow: View {
    
    @Namespace private var geometryNamespace
    @EnvironmentObject var model:WordModel

    @State var attempts:Int = 0
    @State var isSelecting:Bool = false
    @State var selectingIndex:Int = 0
    
    var body: some View {
        
        VStack{
            LargeInputRow(
            numberOfItems: 5,
            alphabet: model.alphabet,
            size: 38,
            desiredSpacing: 2,
            attempts: $attempts,
            isSelecting: $isSelecting,
            selectingIndex: $selectingIndex,
            namespace: geometryNamespace
        )
            Text("\(isSelecting ? "true" : "false")")
        }
        
    }
}
