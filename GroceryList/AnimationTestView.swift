//
//  AnimationTestView.swift
//  GroceryList
//
//  Created by Asir Bygud on 11/17/23.
//

import SwiftUI

struct AnimationTestView: View {
    @State private var switchOn = false
    let colors: [Color] = [.red, .green, .blue, .purple, .orange, .pink, .teal, .mint, .gray, .indigo]
    let imageName: [String] = ["One", "Two", "Three", "Four", "Five"]
    var images: [String] = []
    @State private var someNumber = 0
    
    init(switchOn: Bool = false) {
        images.append(imageName.randomElement()!)
        images.append(imageName.randomElement()!)
        images.append(imageName.randomElement()!)
        images.append(imageName.randomElement()!)
        images.append(imageName.randomElement()!)
    }
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(1...5, id: \.self) { number in
                    ZStack {
                        if number != 5 && number != 2 {
                            Image(images[number - 1])
                                .resizable()
                                .scaledToFill()
                                .zIndex(2)
                        }
                        
                        ZStack {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(colors.randomElement()!)
                                .zIndex(0)
                            
                            Text("\(someNumber)")
                                .foregroundStyle(.white)
                                .font(.largeTitle)
                                .fontDesign(.rounded)
                                .zIndex(1)
                                .contentTransition(.numericText(value: Double(someNumber)))
                        }
                        .offset(x: -60, y: -110)
                        .zIndex(1)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.ultraThinMaterial)
                            .frame(width: 200, height: 300)
                            .zIndex(0)
                    }
                    .frame(width: 200, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .offset(x: Double.random(in: -100...100), y: Double.random(in: -100...100))
                    .rotationEffect(.degrees(switchOn ? 0 : -45 + 15 * Double(number)), anchor: .bottom)
                    .scaleEffect(switchOn ? 0.2 * Double(number) : 1)
                    .animation(.spring(.bouncy(duration: 0.5, extraBounce: 0.15), blendDuration: 3), value: switchOn)
                }
            }
            .frame(height: 600)
            Button("Switch") {
                withAnimation {
                    switchOn.toggle()
                    someNumber += 1
                    if someNumber >= 100 {
                        someNumber = 0
                    }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
}

#Preview {
    AnimationTestView()
}
