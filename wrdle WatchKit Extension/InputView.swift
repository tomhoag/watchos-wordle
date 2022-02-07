//
//  InputView.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import SwiftUI

struct InputView: View {
    @Binding var presentedAsModal: Bool
    @Binding var word: String
    
    var body: some View {
        TextField("", text: $word)
    }
}


struct Foo:View {
    @State var present = true
    @State var word = "WOOT"
    
    var body: some View {
        InputView(presentedAsModal: $present, word: $word)
    }
}
struct InputView_Previews: PreviewProvider {
    @State var present = true
    static var previews: some View {
        Foo()
    }
}
