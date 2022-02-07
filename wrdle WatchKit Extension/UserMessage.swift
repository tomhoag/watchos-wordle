//
//  UserMessage.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/14/22.
//

import SwiftUI

struct UserMessage: View {
    
    @Binding var message:String
    var delay:CGFloat
    @State private var degrees:CGFloat = 90
    
    var body: some View {
        Text(message)
            .font(.system(.headline))
            .foregroundColor(.black)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 20.0)
                    .foregroundColor(.appGray)
            )
            .rotation3DEffect(.degrees(degrees), axis: (x: 1, y:0, z:0))
            .onChange(of: message) {
                if($0 != "") {
                    withAnimation { self.degrees = 0 }
                }
            }
            .onAnimationCompleted(for: degrees) {
                if(self.degrees == 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation { self.degrees = -90 }
                    }
                } else {
                    message = ""
                    self.degrees = 90
                }
            }
    }
}

struct FooUserMessage: View {
    @State var message = "Woot Yo"
    var body: some View {
        UserMessage(message: $message, delay: 1.5)
    }
}

struct UserMessage_Previews: PreviewProvider {
    static var previews: some View {
        FooUserMessage(message: "Woot")
    }
}
