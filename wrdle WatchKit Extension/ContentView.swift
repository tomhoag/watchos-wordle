//
//  ContentView.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import SwiftUI



struct ContentView: View {
    @StateObject var model = WordModel()
    
    
    var body: some View {
        WordTable().environmentObject(model)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
