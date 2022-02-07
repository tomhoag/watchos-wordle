//
//  Fireworks.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/18/22.
//

import SwiftUI

struct Fireworks: View {
    private let colors = [Color.red, Color.green, Color.blue, Color.yellow, Color.purple, Color.orange, Color.cyan, Color.indigo, Color.mint, Color.pink, Color.teal]
    var word:String
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width/5
            let size:CGFloat = w
            ZStack {
                ForEach(0..<word.count) { index in
                    let left:CGFloat = CGFloat(index) * w
                    let right:CGFloat = CGFloat(index+1) * w
                    Text(word[index])
                        .font(.system(.headline))
                        .frame(width: size, height: size, alignment: .center)
                        .modifier(ParticlesModifier(duration: 7.5))
                        .offset(x: CGFloat.random(in:left...right), y:CGFloat.random(in:0...geo.size.height))
                        .foregroundColor(colors.randomElement()!)
                }
            }
        }
    }
}

struct Fireworks_Previews: PreviewProvider {
    static var previews: some View {
        Fireworks(word:"ADIEU")
    }
}


struct FireworkParticlesGeometryEffect : GeometryEffect {
    var time : Double
    var speed = Double.random(in: 10 ... 30)
    var direction = Double.random(in: -Double.pi ...  Double.pi)
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time
        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}


struct ParticlesModifier: ViewModifier {
    @State var time = 0.0
    @State var scale = 0.5
    var duration:CGFloat
    
    func body(content: Content) -> some View {
        ZStack {
            ForEach(0..<80, id: \.self) { index in
                content
                    .hueRotation(Angle(degrees: time * 80))
                    .scaleEffect(scale)
                    .modifier(FireworkParticlesGeometryEffect(time: time))
                    .opacity(((duration-time) / duration))
            }
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
                self.scale = 2.0
            }
        }
    }
}
